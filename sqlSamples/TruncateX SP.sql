CREATE PROCEDURE [Development].[TruncateX] 
   @TableName    SYSNAME
 , @TableSchema  SYSNAME = NULL
AS
  BEGIN
    SET NOCOUNT ON;
    SET @TableSchema = ISNULL(@TableSchema, 'dbo'); -- assume the dbo schema by default
    DECLARE 
           @FKSTableVarOri TABLE
     (
       [PKTABLE_QUALIFIER]  SYSNAME
     , [PKTABLE_OWNER]      SYSNAME
     , [PKTABLE_NAME]       SYSNAME
     , [PKCOLUMN_NAME]      SYSNAME
     , [FKTABLE_QUALIFIER]  SYSNAME
     , [FKTABLE_OWNER]      SYSNAME
     , [FKTABLE_NAME]       SYSNAME
     , [FKCOLUMN_NAME]      SYSNAME
     , [KEY_SEQ]            SMALLINT
     , [UPDATE_RULE]        SMALLINT
     , [DELETE_RULE]        SMALLINT
     , [FK_NAME]            SYSNAME
     , [PK_NAME]            SYSNAME
     , [DEFERRABILITY]      SMALLINT
    );
    -- In-memory table to store the consolidate relationships

    DECLARE 
           @FKSTableVar TABLE
     (
       [PKTABLE_OWNER]  SYSNAME
     , [PKTABLE_NAME]   SYSNAME
     , [PKCOLUMN_NAME]  SYSNAME
     , [FKTABLE_OWNER]  SYSNAME
     , [FKTABLE_NAME]   SYSNAME
     , [FKCOLUMN_NAME]  SYSNAME
     , [UPDATE_RULE]    SMALLINT
     , [DELETE_RULE]    SMALLINT
     , [FK_NAME]        SYSNAME
    );
    --Store into the first table declared, the results of the sp_fkeys execution

    INSERT INTO @FKSTableVarOri
    EXEC [sp_fkeys] 
         @pktable_name = @TableName
       , @pktable_owner = @TableSchema;
    -- Consolidate the relationships, by concatenating the implied columns in one string

    INSERT INTO @FKSTableVar
           SELECT 
               [PKTABLE_OWNER]
             , [PKTABLE_NAME]
             , STRING_AGG(
                          '[' + 
                          [PKCOLUMN_NAME] + 
                          ']', ',') AS [PKCOLUMN_NAME]
             , [FKTABLE_OWNER]
             , [FKTABLE_NAME]
             , STRING_AGG(
                          '[' + 
                          [FKCOLUMN_NAME] + 
                          ']', ',') AS [FKCOLUMN_NAME]
             , [UPDATE_RULE]
             , [DELETE_RULE]
             , [FK_NAME]
           FROM 
              @FKSTableVarOri
           GROUP BY 
               [FK_NAME]
             , [PKTABLE_OWNER]
             , [PKTABLE_NAME]
             , [FKTABLE_OWNER]
             , [FKTABLE_NAME]
             , [UPDATE_RULE]
             , [DELETE_RULE];
    --Check if there are relationships

    DECLARE 
           @References  SMALLINT;
    SELECT 
        @References = COUNT(*)
    FROM 
       @FKSTableVar;
    IF @References > 0 --there are relationships
      BEGIN
        --Check if there are dependent rows in child tables
        DECLARE 
               @Counters  NVARCHAR(MAX);
        SELECT 
            @Counters = STRING_AGG(
                                   '(select count(*) from ['
                                   + 
                                   [FKTABLE_OWNER] + 
                                   '].[' + 
                                   [FKTABLE_NAME] + 
                                   '])', '+')
        FROM 
           @FKSTableVar;
        SET @Counters =
                        'Select @ForeignRows=' + 
                        @Counters;
        PRINT @Counters;
        -- Execute the generated scripts to get the row counts
        DECLARE 
               @ForeignRows  INT;
        EXEC [sp_executesql] 
             @Counters
           , N'@ForeignRows int OUTPUT'
           , @ForeignRows OUTPUT;
        SELECT 
            @ForeignRows;
        IF @ForeignRows > 0 -- There are dependent rows
          BEGIN
            RAISERROR(
            'There are dependent rows in other tables', 10,
            1);
          END;
           ELSE
        -- No problem. Ok to proceed
          BEGIN
            DECLARE 
                   @DropRefs    NVARCHAR(MAX)
                 , @CreateRefs  NVARCHAR(MAX);
            -- Build the script to drop the relationships
            SELECT 
                @DropRefs = STRING_AGG(
                                       'ALTER TABLE [' + 
                                       [FKTABLE_OWNER] + 
                                       '].[' + 
                                       [FKTABLE_NAME] + 
                                       '] DROP CONSTRAINT ['
                                       + 
                                       [FK_NAME] + 
                                       ']', ';')
            FROM 
               @FKSTableVar;
            -- Build the script to re-create the relationships
            SELECT 
                @CreateRefs = STRING_AGG(
                                         'ALTER TABLE [' + 
                                         [FKTABLE_OWNER] + 
                                         '].[' + 
                                         [FKTABLE_NAME] + 
                                         ']  WITH CHECK ADD  CONSTRAINT ['
                                         + 
                                         [FK_NAME] + 
                                         '] FOREIGN KEY(' + 
                                         [FKCOLUMN_NAME] + 
                                         ') REFERENCES [' + 
                                         [PKTABLE_OWNER] + 
                                         '].[' + 
                                         [PKTABLE_NAME] + 
                                         ']  (' + 
                                         [PKCOLUMN_NAME] + 
                                         ') ' + 
                                         (CASE
                                         [DELETE_RULE]
                                             WHEN 1
                                             THEN
                                             ' ON DELETE CASCADE '
                                             ELSE ''
                                          END) + 
                                         (CASE
                                         [UPDATE_RULE]
                                             WHEN 1
                                             THEN
                                             ' ON UPDATE CASCADE '
                                             ELSE ''
                                          END), ';')
            FROM 
               @FKSTableVar;
            -- Execute the drop relationships script
            EXEC [sp_executesql] 
                 @DropRefs;
          END;
      END;
    -- Built the truncate statement

    DECLARE 
           @Truncate  NVARCHAR(MAX) =
                                      N'TRUNCATE TABLE [' + 
                                      @TableSchema + 
                                      '].[' + 
                                      @TableName + 
                                      ']';
    -- Execute the Truncate

    EXEC [sp_executesql] 
         @Truncate;
    IF @References > 0
      BEGIN -- if there are relationships, recreate them
        EXEC [sp_executesql] 
             @CreateRefs;
      END;
  END;