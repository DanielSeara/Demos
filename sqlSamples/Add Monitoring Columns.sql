DECLARE 
   @Schema SYSNAME = 'dbo';
DECLARE 
   @TableName SYSNAME = 'Employees';
DECLARE 
   @Isthere INT;
DECLARE 
   @ColumnName SYSNAME = 'Created by';
DECLARE 
   @CheckForColumn NVARCHAR(300) =
   'select @Isthere =count(*) from INFORMATION_SCHEMA.COLUMNS T where TABLE_SCHEMA=@schema and TABLE_NAME=@TableName and T.COLUMN_NAME=@ColumnName'
;
EXEC [sp_executesql] 
   @CheckForColumn
 ,
 N'@Schema sysname,@TableName sysname,@ColumnName sysname,@Isthere int OUTPUT'
 , @schema
 , @TableName
 , @ColumnName
 , @Isthere OUTPUT;
DECLARE 
   @SqlToExecute NVARCHAR(MAX);
IF @Isthere = 0
  BEGIN
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD ['
                        + @columnName
                        + '] nvarchar(150) NULL';
    EXEC [sp_executesql] 
       @SqlToExecute;
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD CONSTRAINT [DF_'
                        + @TableName
                        + '_'
                        + @columnName
                        + '] DEFAULT CURRENT_USER FOR ['
                        + @columnName
                        + ']';
    EXEC [sp_executesql] 
       @SqlToExecute;
  END;
SET @ColumnName = 'Modified By';
EXEC [sp_executesql] 
   @CheckForColumn
 ,
 N'@Schema sysname,@TableName sysname,@ColumnName sysname,@Isthere int OUTPUT'
 , @schema
 , @TableName
 , @ColumnName
 , @Isthere OUTPUT;
IF @Isthere = 0
  BEGIN
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD ['
                        + @columnName
                        + '] nvarchar(150) NULL';
    EXEC [sp_executesql] 
       @SqlToExecute;
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD CONSTRAINT [DF_'
                        + @TableName
                        + '_'
                        + @columnName
                        + '] DEFAULT CURRENT_USER FOR ['
                        + @columnName
                        + ']';
    EXEC [sp_executesql] 
       @SqlToExecute;
  END;
SET @ColumnName = 'Created';
EXEC [sp_executesql] 
   @CheckForColumn
 ,
 N'@Schema sysname,@TableName sysname,@ColumnName sysname,@Isthere int OUTPUT'
 , @schema
 , @TableName
 , @ColumnName
 , @Isthere OUTPUT;
IF @Isthere = 0
  BEGIN
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD ['
                        + @columnName
                        + '] datetime2(7) NULL';
    EXEC [sp_executesql] 
       @SqlToExecute;
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD CONSTRAINT [DF_'
                        + @TableName
                        + '_'
                        + @columnName
                        + '] DEFAULT SYSUTCDATETIME() FOR ['
                        + @columnName
                        + ']';
    EXEC [sp_executesql] 
       @SqlToExecute;
  END;
SET @ColumnName = 'Modified';
EXEC [sp_executesql] 
   @CheckForColumn
 ,
 N'@Schema sysname,@TableName sysname,@ColumnName sysname,@Isthere int OUTPUT'
 , @schema
 , @TableName
 , @ColumnName
 , @Isthere OUTPUT;
IF @Isthere = 0
  BEGIN
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD ['
                        + @columnName
                        + '] datetime2(7) NULL';
    EXEC [sp_executesql] 
       @SqlToExecute;
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD CONSTRAINT [DF_'
                        + @TableName
                        + '_'
                        + @columnName
                        + '] DEFAULT SYSUTCDATETIME() FOR ['
                        + @columnName
                        + ']';
    EXEC [sp_executesql] 
       @SqlToExecute;
  END;
SET @ColumnName = 'Active';
EXEC [sp_executesql] 
   @CheckForColumn
 ,
 N'@Schema sysname,@TableName sysname,@ColumnName sysname,@Isthere int OUTPUT'
 , @schema
 , @TableName
 , @ColumnName
 , @Isthere OUTPUT;
IF @Isthere = 0
  BEGIN
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD ['
                        + @columnName
                        + '] bit NULL';
    EXEC [sp_executesql] 
       @SqlToExecute;
    SET @SqlToExecute =
                        'ALTER TABLE ['
                        + @schema
                        + '].['
                        + @TableName
                        + '] ADD CONSTRAINT [DF_'
                        + @TableName
                        + '_'
                        + @columnName
                        + '] DEFAULT 1 FOR ['
                        + @columnName
                        + ']';
    EXEC [sp_executesql] 
       @SqlToExecute;
  END;