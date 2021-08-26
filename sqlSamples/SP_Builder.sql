DECLARE 
   @SchemaName SYSNAME = 'dbo';
DECLARE 
   @TableName SYSNAME = '<Type your table name here>';

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

/* This table is used to prepare columns information*/

DECLARE 
   @ColumnsDefs TABLE
(
   [AtSign]     NVARCHAR(MAX) NULL
 , [ColumnName] NVARCHAR(MAX) NULL
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
   @Parameters     NVARCHAR(MAX)
 , @Insert         NVARCHAR(MAX)
 , @identityColumn NVARCHAR(300)
 , @where          NVARCHAR(MAX)
 , @ParamsDelete   NVARCHAR(MAX)
 , @Update         NVARCHAR(MAX)
 , @Delete         NVARCHAR(MAX);

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
            WHEN 0 THEN ISNULL([CHARACTER_MAXIMUM_LENGTH],
            [NUMERIC_PRECISION])
                                         ELSE NULL
          END AS [Expr1]
        , [INFORMATION_SCHEMA].[COLUMNS].[NUMERIC_SCALE]
        , [INFORMATION_SCHEMA].[COLUMNS].[IS_NULLABLE]
        , CASE ISNULL([INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].
        [CONSTRAINT_NAME], N'')
            WHEN '' THEN 0
                                         ELSE 1
          END AS [IsPrimaryKey] /* Marks the Primary Keys Columns*/

       FROM    
          [INFORMATION_SCHEMA].[REFERENTIAL_CONSTRAINTS]
            INNER JOIN
              [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE]
            ON
              [INFORMATION_SCHEMA].[REFERENTIAL_CONSTRAINTS].
              [UNIQUE_CONSTRAINT_SCHEMA]
              = [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].
              [TABLE_SCHEMA]
              AND
              [INFORMATION_SCHEMA].[REFERENTIAL_CONSTRAINTS].
              [UNIQUE_CONSTRAINT_NAME]
              = [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].
              [CONSTRAINT_NAME]
              RIGHT OUTER JOIN
                [INFORMATION_SCHEMA].[COLUMNS]
              ON
              [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].
              [TABLE_SCHEMA]
              = [INFORMATION_SCHEMA].[COLUMNS].[TABLE_SCHEMA]
              AND
              [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].[TABLE_NAME]
              = [INFORMATION_SCHEMA].[COLUMNS].[TABLE_NAME]
              AND
              [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE].[COLUMN_NAME]
              = [INFORMATION_SCHEMA].[COLUMNS].[COLUMN_NAME]
       WHERE
             (
                    [INFORMATION_SCHEMA].[COLUMNS].[TABLE_SCHEMA]
                    = @SchemaName)
             AND
             (
                    [INFORMATION_SCHEMA].[COLUMNS].[TABLE_NAME]
                    = @TableName);
/* Mark those columns which are calculated, to not include them in the procedures*/

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

/* mark the column with identity specification, if any*/

UPDATE @ColumnsDefs
  SET     
   [IsIdentity] = [C].[is_identity]
FROM   [sys].[tables] AS [T]
         INNER JOIN
           [sys].[columns] AS [C]
         ON
       [T].object_id
       = [C].object_id
           INNER JOIN
             @ColumnsDefs [CD]
           ON
       [C].[name]
       = [CD].[ColumnName]
WHERE 
      (
             OBJECT_SCHEMA_NAME([T].object_id, DB_ID())
             = @SchemaName)
      AND
      (
             [T].[name]
             = @TableName);

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

/* Add the At sign to make the parameters generation easier*/

UPDATE @ColumnsDefs
  SET     
   [AtSign] = N'@';

/* Create the Parameters for Insert and Update procedures*/

SELECT    
   @Parameters = STRING_AGG(
                            [AtSign]
                            + replace([ColumnName], ' ', '_')
                            + [S1]
                            + [DataType]
                            + [S2]
                            + [OpenPar]
                            + [Length]
                            + [ScaleComma]
                            + [Scale]
                            + [ClosePar]
                            + [EqNull]
                            + [Nullable]
                            + IIF([IsIdentity] = 1, ' OUTPUT', ''),
                            @CrLfComma)
FROM    
   @ColumnsDefs
WHERE
      [IsComputed] = 0
      AND
       [datatype]
       <> 'timestamp';

/* Build the Insert sentence*/

SELECT    
   @Insert =
             ' INSERT INTO ['
             + @SchemaName
             + '].['
             + @TableName
             + ']
     ('
             + STRING_AGG(
                          '['
                          + [ColumnName]
                          + ']', @CrLfComma)
             + ') VALUES('
             + STRING_AGG(
                          [AtSign]
                          + replace([ColumnName], ' ', '_'), @CrLfComma)
             + ')'
FROM    
   @ColumnsDefs
WHERE
      [IsComputed] = 0
      AND
       [datatype]
       <> 'timestamp';

/* Define the Create procedure for Insert*/

SET @Insert =
              'DROP PROCEDURE IF EXISTS ['
              + @schemaName
              + '].['
              + @tablename
              + '_Insert]'
              + @CrLf
              + ' GO'
              + @CrLf
              + 'CREATE PROCEDURE ['
              + @schemaName
              + '].['
              + @tablename
              + '_Insert] ( '
              + @CrLf
              + @Parameters
              + ') '
              + @CrLf
              + ' AS BEGIN '
              + @CrLf
              + @insert;

/* Look for Identity column*/

SELECT    
   @identityColumn = [ColumnName]
FROM    
   @ColumnsDefs
WHERE [IsIdentity] = 1;

/* If there is an Identity column add the statement to get the indentity used for the output parameter*/

IF NOT @identityColumn IS NULL
  BEGIN
    SET @insert =
                  @insert
                  + @CrLf
                  + ' SET @'
                  + @identityColumn
                  + ' = IDENT_CURRENT('
                  + CHAR(39)
                  + '['
                  + @SchemaName
                  + '].['
                  + @tablename
                  + ']'
                  + CHAR(39)
                  + ')'
                  + @CrLf;
  END;

/* Finish the Insert stored procedure*/

SET @insert =
              @insert
              + ' END'
              + @CrLf
              + '  GO'
              + @CrLf;

/* Remove the OUTPUT modifier from the parameters, if any, since it is not needed in update*/

SET @Parameters = replace(@parameters, 'OUTPUT', '');

/* Build the where condition for update and delete sentences, using the Primary keys columns*/

SELECT    
   @where = STRING_AGG(
                       '['
                       + [ColumnName]
                       + ']='
                       + [Atsign]
                       + replace([ColumnName], ' ', '_'), @CrLfAnd)
 , @ParamsDelete = STRING_AGG(
                              [AtSign]
                              + replace([ColumnName], ' ', '_')
                              + [S1]
                              + [DataType]
                              + [S2]
                              + [OpenPar]
                              + [Length]
                              + [ScaleComma]
                              + [Scale]
                              + [ClosePar]
                              + [EqNull]
                              + [Nullable]
                              + IIF([IsIdentity] = 1, ' OUTPUT', ''),
                              @CrLfComma)
FROM    
   @ColumnsDefs
WHERE
      ([IsPk] = 1);

/* Build the Update sentence*/

SELECT    
   @Update =
             ' UPDATE ['
             + @SchemaName
             + '].['
             + @TableName
             + ']'
             + @CrLf
             + ' 
     SET '
             + STRING_AGG(
                          '['
                          + [ColumnName]
                          + ']='
                          + [AtSign]
                          + replace([ColumnName], ' ', '_'), @CrLfComma)
FROM    
   @ColumnsDefs
WHERE
      [IsComputed] = 0
      AND
       [datatype]
       <> 'timestamp'
      AND [IsIdentity] = 0;

/* Build the Update Stored Procedure*/

SET @Update =
              'DROP PROCEDURE IF EXISTS ['
              + @schemaName
              + '].['
              + @tablename
              + '_Update]'
              + @CrLf
              + ' GO'
              + @CrLf
              + 'CREATE PROCEDURE ['
              + @schemaName
              + '].['
              + @tablename
              + '_Update]'
              + @CrLf
              + ' ( '
              + @Parameters
              + ') AS '
              + @CrLf
              + ' BEGIN '
              + @Update;

/* Build the Delete sentence*/

SET @Delete =
              'Delete from ['
              + @SchemaName
              + '].['
              + @TableName
              + ']'
              + @CrLf
              + '  WHERE ';
SET @Update =
              @Update
              + +@CrLf
              + ' WHERE '
              + @where
              + ''
              + @CrLf
              + '  END'
              + @CrLf
              + '  GO';

/* Build the Delete Stored Procedure*/

SET @Delete =
              'DROP PROCEDURE IF EXISTS ['
              + @schemaName
              + '].['
              + @tablename
              + '_Delete]'
              + @CrLf
              + ' GO'
              + @CrLf
              + 'CREATE PROCEDURE ['
              + @schemaName
              + '].['
              + @tablename
              + '_Delete] ( '
              + @ParamsDelete
              + ')'
              + @CrLf
              + '  AS BEGIN '
              + @CrLf
              + ' '
              + @Delete
              + @where
              + @CrLf
              + ' END '
              + @CrLf
              + ' GO';

/* Display the final result.*/

PRINT @Insert;
PRINT @Update;
PRINT @Delete;