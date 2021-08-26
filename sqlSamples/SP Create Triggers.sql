CREATE PROCEDURE [Development].[CreateTriggers]
(
   @TableName         SYSNAME
 , @SchemaName        SYSNAME = NULL
 , @DestinationSchema SYSNAME = NULL
)
AS
  BEGIN
    DECLARE 
       @Suffix NVARCHAR(5);
    SET @SchemaName = ISNULL(@SchemaName, 'dbo');
    IF @DestinationSchema IS NULL
      BEGIN
        SET @DestinationSchema = @schemaName;
        SET @Suffix = '_Hist';
      END;
    SET NOCOUNT ON;
/* 
	Variables
*/
    /* New line*/
    DECLARE 
       @CrLf NCHAR(2) =
                        CHAR(13)
                        + CHAR(10);

    /* New line plus comma*/
    DECLARE 
       @CrLfComma NCHAR(3) = @CrLf + ',';
    DECLARE 
       @CrLfAnd NVARCHAR(8) = @CrLf + ' AND ';
    DECLARE 
       @apostrophe NCHAR(1) = CHAR(39);
    /* This table is used to prepare columns information*/
    DECLARE 
       @ColumnsDefs TABLE
    (
       [ColumnName] NVARCHAR(MAX) NULL
     , [S1]         NVARCHAR(1) DEFAULT(' ')
     , [DataType]   NVARCHAR(100) NULL
     , [S2]         NVARCHAR(1) DEFAULT(' ')
     , [OpenPar]    NVARCHAR(1) NULL
     , [Length]     NVARCHAR(6) NULL
     , [ScaleComma] NVARCHAR(1) NULL
     , [Scale]      NVARCHAR(3) NULL
     , [ClosePar]   NVARCHAR(1) NULL
     , [EqNull]     NVARCHAR(10) NULL
     , [Nullable]   NVARCHAR(3) NULL
     , [IsIdentity] BIT
     , [IsPk]       BIT
     , [IsComputed] BIT DEFAULT(0)
    );
    DECLARE 
       @SqlSentence NVARCHAR(MAX)
     , @SqlFields   NVARCHAR(MAX)
     , @SqlValues   NVARCHAR(MAX);
/* 
	End of Variables
*/
    /* Add one row per column from the table to process*/

    INSERT INTO @ColumnsDefs
      (
       [ColumnName]
     , [DataType]
     , [Length]
     , [Scale]
     , [Nullable]
     , [IsPk]
      )
           SELECT DISTINCT    
              [INFORMATION_SCHEMA].[COLUMNS].[COLUMN_NAME]
            , [INFORMATION_SCHEMA].[COLUMNS].[DATA_TYPE]
            , CASE
                   CHARINDEX('int', [Data_Type])
                   + CHARINDEX('float', [Data_Type])
                   + CHARINDEX('real', [Data_Type])
                   + CHARINDEX('money', [Data_Type])
                   + CHARINDEX('geo', [Data_Type])
                   + CHARINDEX('image', [Data_Type])
                   + CHARINDEX('text', [Data_Type])
                   + CHARINDEX('xml', [Data_Type])
                   + CHARINDEX('sql_variant', [Data_Type])
                   + CHARINDEX('hierarchyid', [Data_Type])
                WHEN 0 THEN ISNULL([CHARACTER_OCTET_LENGTH],
                [NUMERIC_PRECISION])
                                             ELSE NULL
              END AS [Expr1]
              /* This define the column size, when required, or the numeric precision for the numeric columns */
            , [INFORMATION_SCHEMA].[COLUMNS].[NUMERIC_SCALE]
            , [INFORMATION_SCHEMA].[COLUMNS].[IS_NULLABLE]
            , CASE ISNULL([INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].
            [CONSTRAINT_NAME], N'')
                WHEN '' THEN 0
                                             ELSE 1
              END AS [IsPrimaryKey]
           /* mark the prmary keys columns*/
           FROM    
              [INFORMATION_SCHEMA].[COLUMNS]
                LEFT OUTER JOIN
                  [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE]
                ON
                  [INFORMATION_SCHEMA].[COLUMNS].[TABLE_SCHEMA]
                  = [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].
                  [TABLE_SCHEMA]
                  AND
                  [INFORMATION_SCHEMA].[COLUMNS].[TABLE_NAME]
                  = [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].
                  [TABLE_NAME]
                  AND
                  [INFORMATION_SCHEMA].[COLUMNS].[COLUMN_NAME]
                  = [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].
                  [COLUMN_NAME]
           WHERE
                 (
                        [INFORMATION_SCHEMA].[COLUMNS].[TABLE_SCHEMA]
                        = @SchemaName)
                 AND
                 (
                        [INFORMATION_SCHEMA].[COLUMNS].[TABLE_NAME]
                        = @TableName);
    INSERT INTO @ColumnsDefs
      (
       [ColumnName]
     , [DataType]
      )
    VALUES
    (
      'DateChanged'
    , 'datetime2(7)'
    );
    INSERT INTO @ColumnsDefs
      (
       [ColumnName]
     , [DataType]
     , [Length]
      )
    VALUES
    (
      'UserChanged'
    , 'nvarchar'
    , 150
    );
    INSERT INTO @ColumnsDefs
      (
       [ColumnName]
     , [DataType]
     , [Length]
      )
    VALUES
    (
      'ACTION;'
    , 'nvarchar'
    , 15
    );
    UPDATE @ColumnsDefs
      SET     
       [IsComputed] = 1
    FROM   @ColumnsDefs [CD]
             LEFT OUTER JOIN
               [sys].[computed_columns]
             ON
           [CD].[ColumnName]
           = [sys].[computed_columns].[name]
    WHERE 
          (
                 [sys].[computed_columns].object_id
                 = OBJECT_ID(
                             QUOTENAME(@SchemaName)
                             + '.'
                             + QUOTENAME(@TableName)));

    /* Change the size for the MAX columns*/

    UPDATE @ColumnsDefs
      SET     
       [Length] = N'MAX'
    WHERE 
          ([Length] = N'-1');

    /* Add an open parenthesis to those columns with size or numeric precision*/

    UPDATE @ColumnsDefs
      SET     
       [OpenPar] = N'('
    WHERE      
     (NOT
     ([Length] IS NULL
     )
     );

    /* Add comma for those columns with scale*/

    UPDATE @ColumnsDefs
      SET     
       [ScaleComma] = N','
    WHERE      
     (NOT
     ([OpenPar] IS NULL
     )
     )
     AND
          ([Scale] <> N'0');

    /* Add a closing parenthesis when needed*/

    UPDATE @ColumnsDefs
      SET     
       [ClosePar] = N')'
    WHERE      
     (NOT
     ([Length] IS NULL
     )
     );

    /* Define the columns which accept nulls*/

    UPDATE @ColumnsDefs
      SET     
       [EqNull] = N'= NULL'
    WHERE 
          (
                 [Nullable]
                 = N'YES');

    /* Clean the scale for those columns without numeric precision*/

    UPDATE @ColumnsDefs
      SET     
       [Scale] = N''
    WHERE      
     (
     ([Scale] = N'0')
     OR
     ([OpenPar] IS NULL
     )
     );

    /* Replace the null values in the all the rows by empty strings */

    UPDATE @ColumnsDefs
      SET     
       [DataType] = N''
    WHERE      
     ([DataType] IS NULL
     );
    UPDATE @ColumnsDefs
      SET     
       [OpenPar] = N''
    WHERE      
     ([OpenPar] IS NULL
     );
    UPDATE @ColumnsDefs
      SET     
       [Length] = N''
    WHERE      
     ([Length] IS NULL
     );
    UPDATE @ColumnsDefs
      SET     
       [ScaleComma] = N''
    WHERE      
     ([ScaleComma] IS NULL
     );
    UPDATE @ColumnsDefs
      SET     
       [Scale] = N''
    WHERE      
     ([Scale] IS NULL
     );
    UPDATE @ColumnsDefs
      SET     
       [ClosePar] = N''
    WHERE      
     ([ClosePar] IS NULL
     );
    UPDATE @ColumnsDefs
      SET     
       [EqNull] = N''
    WHERE      
     ([EqNull] IS NULL
     );
    UPDATE @ColumnsDefs
      SET     
       [Nullable] = N'';
    SELECT     
       @SqlSentence = STRING_AGG(
                                 '['
                                 + replace([ColumnName], ' ', '_')
                                 + ']'
                                 + [S1]
                                 + [DataType]
                                 + [S2]
                                 + [OpenPar]
                                 + [Length]
                                 + [ScaleComma]
                                 + [Scale]
                                 + [ClosePar]
                                 + [EqNull]
                                 + [Nullable], @CrLfComma)
    FROM     
       @ColumnsDefs
    WHERE
           [datatype]
           <> 'timestamp';
    SET @SqlSentence =
                       'CREATE TABLE ['
                       + @DestinationSchema
                       + '].['
                       + @TableName
                       + @Suffix
                       + ']('
                       + @SqlSentence
                       + ')';
    SELECT     
       @SqlFields = STRING_AGG(
                               '['
                               + replace([ColumnName], ' ', '_')
                               + ']', @CrLfComma)
    FROM     
       @ColumnsDefs
    WHERE
           [datatype]
           <> 'timestamp';
    SELECT     
       @SqlValues = STRING_AGG(
                               'O.['
                               + replace([ColumnName], ' ', '_')
                               + ']', @CrLfComma)
    FROM     
       @ColumnsDefs
    WHERE
           [datatype]
           <> 'timestamp'
           AND [ColumnName] NOT IN
    (
       'DateChanged'
     , 'UserChanged'
     , 'Action'
    );
    EXEC [sp_executesql] 
       @sqlSentence;
    SET @SqlSentence =
                       'CREATE TRIGGER ['
                       + @SchemaName
                       + '].['
                       + @TableName
                       + '_TInsert]'
                       + 'ON ['
                       + @SchemaName
                       + '].['
                       + @TableName
                       + ']'
                       + @CrLf
                       + 'AFTER INSERT AS '
                       + @CrLf
                       + '  BEGIN'
                       + @CrLf
                       + '    SET NOCOUNT ON;'
                       + @CrLf
                       + '    INSERT INTO ['
                       + @SchemaName
                       + '].['
                       + @TableName
                       + '_Hist]('
                       + @SqlFields
                       + '   )           SELECT '
                       + @SqlValues
                       + ', SYSUTCDATETIME(), USER_NAME(), '
                       + @apostrophe
                       + 'Insert'
                       + @apostrophe
                       + ' FROM  [inserted] [O];  END';
    EXEC [sp_executesql] 
       @sqlSentence;
    SET @SqlSentence =
                       'CREATE TRIGGER ['
                       + @SchemaName
                       + '].['
                       + @TableName
                       + '_TUD] ON ['
                       + @SchemaName
                       + '].['
                       + @TableName
                       + ']'
                       + @CrLf
                       + 'AFTER  UPDATE, DELETE AS '
                       + @CrLf
                       + '  BEGIN'
                       + @CrLf
                       + '    DECLARE @Action NVARCHAR(15) = '
                       + @apostrophe
                       + 'Update'
                       + @apostrophe
                       +
                       'IF NOT EXISTS
     (
       SELECT 
          *
       FROM 
          [inserted]
     )
      BEGIN
        SET @Action = '
                       + @apostrophe
                       + 'Delete'
                       + @apostrophe
                       + '
      END;
    SET NOCOUNT ON;'
                       + @CrLf
                       + '    INSERT INTO ['
                       + @SchemaName
                       + '].['
                       + @TableName
                       + '_Hist]
      ('
                       + @SqlFields
                       + ')           SELECT '
                       + @SqlValues
                       +
                       '
            , SYSUTCDATETIME()
            , USER_NAME()
            , @Action
           FROM 
              [deleted] [O];
  END;';
    EXEC [sp_executesql] 
       @sqlSentence;
  END;
GO