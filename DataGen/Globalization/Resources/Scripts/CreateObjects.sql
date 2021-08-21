/****** Object:  StoredProcedure [@SCHEMA@].[LanguagesByCountry_Update]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[LanguagesByCountry_Update]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[LanguagesByCountry_Insert]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[LanguagesByCountry_Insert]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[LanguagesByCountry_Delete]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[LanguagesByCountry_Delete]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Languages_Update]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[Languages_Update]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Languages_Insert]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[Languages_Insert]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Languages_Delete]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[Languages_Delete]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Countries_Update]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[Countries_Update]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Countries_Insert]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[Countries_Insert]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Countries_Delete]    Script Date: 21/08/2021 10:59:34 ******/
DROP PROCEDURE IF EXISTS [@SCHEMA@].[Countries_Delete]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[LanguagesByCountry]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[LanguagesByCountry] DROP CONSTRAINT[FK_LanguagesByCountry_Languages1]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[LanguagesByCountry]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[LanguagesByCountry] DROP CONSTRAINT[FK_LanguagesByCountry_Languages]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[LanguagesByCountry]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[LanguagesByCountry] DROP CONSTRAINT[FK_LanguagesByCountry_Countries]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[LanguagesByCountry]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[LanguagesByCountry] DROP CONSTRAINT[DF_LanguagesByCountry_InUse]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[Languages]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[Languages] DROP CONSTRAINT[DF_Languages_InUse]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[Languages]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[Languages] DROP CONSTRAINT[DF_Languages_RightToLeft]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[Countries]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[Countries] DROP CONSTRAINT[DF_Countries_IsMetric]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[Countries]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[Countries] DROP CONSTRAINT[DF_Countries_InUse_1]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[@SCHEMA@].[Countries]') AND type in (N'U'))
ALTER TABLE [@SCHEMA@].[Countries] DROP CONSTRAINT[DF_Countries_InUse]
GO
/****** Object:  Table [@SCHEMA@].[LanguagesByCountry]    Script Date: 21/08/2021 10:59:34 ******/
DROP TABLE IF EXISTS [@SCHEMA@].[LanguagesByCountry]
GO
/****** Object:  Table [@SCHEMA@].[Languages]    Script Date: 21/08/2021 10:59:34 ******/
DROP TABLE IF EXISTS [@SCHEMA@].[Languages]
GO
/****** Object:  Table [@SCHEMA@].[Countries]    Script Date: 21/08/2021 10:59:34 ******/
DROP TABLE IF EXISTS [@SCHEMA@].[Countries]
GO
/****** Object:  Schema [@SCHEMA@]    Script Date: 21/08/2021 10:59:34 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'@SCHEMA@')
   EXEC sys.sp_executesql N'CREATE SCHEMA [@SCHEMA@]'
GO
/****** Object:  Table [@SCHEMA@].[Countries]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [@SCHEMA@].[Countries](
   [GeoId] [int] NOT NULL,
   [ISO] [nvarchar](3) NULL,
   [Native Name] [nvarchar](200) NULL,
   [English Name] [nvarchar](200) NULL,
   [Windows] [nvarchar](3) NULL,
   [DDI] [smallint] NULL,
   [Currency Name] [nvarchar](100) NULL,
   [English Currency Name] [nvarchar](100) NULL,
   [Currency Symbol] [nvarchar](5) NULL,
   [ISOCurrency] [nvarchar](10) NULL,
   [InUse] [bit] NOT NULL,
   [IsMetric] [bit] NOT NULL,
   [Flag] [image] NULL,
   [Longitude] [decimal](18, 6) NULL,
   [Latitude] [decimal](18, 6) NULL,
 CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED 
(
   [GeoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [@SCHEMA@].[Languages]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [@SCHEMA@].[Languages](
   [Culture] [nvarchar](20) NOT NULL,
   [Local Name] [nvarchar](100) NULL,
   [English Name] [varchar](100) NULL,
   [LCID] [smallint] NOT NULL,
   [ANSI Code Page] [smallint] NULL,
   [OEM Code Page] [smallint] NULL,
   [Mac Code Page] [smallint] NULL,
   [EBCDIC Code Page] [smallint] NULL,
   [List Separator] [nvarchar](2) NULL,
   [RightToLeft] [bit] NOT NULL,
   [NumberFormatJSON] [nvarchar](max) NULL,
   [DateTimeFormatJSON] [nvarchar](max) NULL,
   [TextInfoJSON] [nvarchar](max) NULL,
   [IsNeutralCulture] [bit] NULL,
   [InUse] [bit] NULL,
 CONSTRAINT [PK_Languages] PRIMARY KEY CLUSTERED 
(
   [Culture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [@SCHEMA@].[LanguagesByCountry]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [@SCHEMA@].[LanguagesByCountry](
   [Culture] [nvarchar](20) NULL,
   [GeoId] [int] NULL,
   [InUse] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [@SCHEMA@].[Countries] ADD  CONSTRAINT [DF_Countries_InUse]  DEFAULT ((0)) FOR [ISOCurrency]
GO
ALTER TABLE [@SCHEMA@].[Countries] ADD  CONSTRAINT [DF_Countries_InUse_1]  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [@SCHEMA@].[Countries] ADD  CONSTRAINT [DF_Countries_IsMetric]  DEFAULT ((1)) FOR [IsMetric]
GO
ALTER TABLE [@SCHEMA@].[Languages] ADD  CONSTRAINT [DF_Languages_RightToLeft]  DEFAULT ((0)) FOR [RightToLeft]
GO
ALTER TABLE [@SCHEMA@].[Languages] ADD  CONSTRAINT [DF_Languages_InUse]  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [@SCHEMA@].[LanguagesByCountry] ADD  CONSTRAINT [DF_LanguagesByCountry_InUse]  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [@SCHEMA@].[LanguagesByCountry]  WITH CHECK ADD  CONSTRAINT [FK_LanguagesByCountry_Countries] FOREIGN KEY([GeoId])
REFERENCES [@SCHEMA@].[Countries] ([GeoId])
GO
ALTER TABLE [@SCHEMA@].[LanguagesByCountry] CHECK CONSTRAINT [FK_LanguagesByCountry_Countries]
GO
ALTER TABLE [@SCHEMA@].[LanguagesByCountry]  WITH CHECK ADD  CONSTRAINT [FK_LanguagesByCountry_Languages] FOREIGN KEY([Culture])
REFERENCES [@SCHEMA@].[Languages] ([Culture])
GO
ALTER TABLE [@SCHEMA@].[LanguagesByCountry] CHECK CONSTRAINT [FK_LanguagesByCountry_Languages]
GO
ALTER TABLE [@SCHEMA@].[LanguagesByCountry]  WITH CHECK ADD  CONSTRAINT [FK_LanguagesByCountry_Languages1] FOREIGN KEY([Culture])
REFERENCES [@SCHEMA@].[Languages] ([Culture])
GO
ALTER TABLE [@SCHEMA@].[LanguagesByCountry] CHECK CONSTRAINT [FK_LanguagesByCountry_Languages1]
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Countries_Delete]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [@SCHEMA@].[Countries_Delete] ( @GeoId int )
  AS BEGIN 
 Delete from [@SCHEMA@].[Countries]
  WHERE [GeoId]=@GeoId
 END 
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Countries_Insert]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [@SCHEMA@].[Countries_Insert] ( 
@Currency_Name nvarchar (200)= NULL
,@Currency_Symbol nvarchar (10)= NULL
,@DDI smallint = NULL
,@English_Currency_Name nvarchar (200)= NULL
,@English_Name nvarchar (400)= NULL
,@Flag image = NULL
,@GeoId int 
,@InUse bit 
,@IsMetric bit 
,@ISO nvarchar (6)= NULL
,@ISOCurrency nvarchar (20)= NULL
,@Latitude decimal (18,6)= NULL
,@Longitude decimal (18,6)= NULL
,@Native_Name nvarchar (400)= NULL
,@Windows nvarchar (6)= NULL) 
 AS BEGIN 
 INSERT INTO [@SCHEMA@].[Countries]
     ([Currency Name]
,[Currency Symbol]
,[DDI]
,[English Currency Name]
,[English Name]
,[Flag]
,[GeoId]
,[InUse]
,[IsMetric]
,[ISO]
,[ISOCurrency]
,[Latitude]
,[Longitude]
,[Native Name]
,[Windows]) VALUES(@Currency_Name
,@Currency_Symbol
,@DDI
,@English_Currency_Name
,@English_Name
,@Flag
,@GeoId
,@InUse
,@IsMetric
,@ISO
,@ISOCurrency
,@Latitude
,@Longitude
,@Native_Name
,@Windows) END
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Countries_Update]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [@SCHEMA@].[Countries_Update]
 ( @Currency_Name nvarchar (200)= NULL
,@Currency_Symbol nvarchar (10)= NULL
,@DDI smallint = NULL
,@English_Currency_Name nvarchar (200)= NULL
,@English_Name nvarchar (400)= NULL
,@Flag image = NULL
,@GeoId int 
,@InUse bit 
,@IsMetric bit 
,@ISO nvarchar (6)= NULL
,@ISOCurrency nvarchar (20)= NULL
,@Latitude decimal (18,6)= NULL
,@Longitude decimal (18,6)= NULL
,@Native_Name nvarchar (400)= NULL
,@Windows nvarchar (6)= NULL) AS 
 BEGIN  UPDATE [@SCHEMA@].[Countries]
 
     SET [Currency Name]=@Currency_Name
,[Currency Symbol]=@Currency_Symbol
,[DDI]=@DDI
,[English Currency Name]=@English_Currency_Name
,[English Name]=@English_Name
,[Flag]=@Flag
,[GeoId]=@GeoId
,[InUse]=@InUse
,[IsMetric]=@IsMetric
,[ISO]=@ISO
,[ISOCurrency]=@ISOCurrency
,[Latitude]=@Latitude
,[Longitude]=@Longitude
,[Native Name]=@Native_Name
,[Windows]=@Windows
 WHERE [GeoId]=@GeoId
  END
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Languages_Delete]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [@SCHEMA@].[Languages_Delete]
(
   @Culture NVARCHAR(40)
)
AS
  BEGIN
    DELETE FROM [@SCHEMA@].[Languages]
    WHERE      
           [Culture]
           = @Culture;
  END; 
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Languages_Insert]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [@SCHEMA@].[Languages_Insert]
(
   @ANSI_Code_Page     SMALLINT      = NULL
 , @Culture            NVARCHAR(40)
 , @DateTimeFormatJSON NVARCHAR(MAX) = NULL
 , @EBCDIC_Code_Page   SMALLINT      = NULL
 , @English_Name       VARCHAR(100)  = NULL
 , @InUse              BIT           = NULL
 , @IsNeutralCulture   BIT           = NULL
 , @LCID               SMALLINT
 , @List_Separator     NVARCHAR(4)   = NULL
 , @Local_Name         NVARCHAR(200) = NULL
 , @Mac_Code_Page      SMALLINT      = NULL
 , @NumberFormatJSON   NVARCHAR(MAX) = NULL
 , @OEM_Code_Page      SMALLINT      = NULL
 , @RightToLeft        BIT
 , @TextInfoJSON       NVARCHAR(MAX) = NULL
)
AS
  BEGIN
    INSERT INTO [@SCHEMA@].[Languages]
      (
       [ANSI Code Page]
     , [Culture]
     , [DateTimeFormatJSON]
     , [EBCDIC Code Page]
     , [English Name]
     , [InUse]
     , [IsNeutralCulture]
     , [LCID]
     , [List Separator]
     , [Local Name]
     , [Mac Code Page]
     , [NumberFormatJSON]
     , [OEM Code Page]
     , [RightToLeft]
     , [TextInfoJSON]
      )
    VALUES
    (
      @ANSI_Code_Page
    , @Culture
    , @DateTimeFormatJSON
    , @EBCDIC_Code_Page
    , @English_Name
    , @InUse
    , @IsNeutralCulture
    , @LCID
    , @List_Separator
    , @Local_Name
    , @Mac_Code_Page
    , @NumberFormatJSON
    , @OEM_Code_Page
    , @RightToLeft
    , @TextInfoJSON
    );
  END;
GO
/****** Object:  StoredProcedure [@SCHEMA@].[Languages_Update]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [@SCHEMA@].[Languages_Update]
(
   @ANSI_Code_Page     SMALLINT      = NULL
 , @Culture            NVARCHAR(40)
 , @DateTimeFormatJSON NVARCHAR(MAX) = NULL
 , @EBCDIC_Code_Page   SMALLINT      = NULL
 , @English_Name       VARCHAR(100)  = NULL
 , @InUse              BIT           = NULL
 , @IsNeutralCulture   BIT           = NULL
 , @LCID               SMALLINT
 , @List_Separator     NVARCHAR(4)   = NULL
 , @Local_Name         NVARCHAR(200) = NULL
 , @Mac_Code_Page      SMALLINT      = NULL
 , @NumberFormatJSON   NVARCHAR(MAX) = NULL
 , @OEM_Code_Page      SMALLINT      = NULL
 , @RightToLeft        BIT
 , @TextInfoJSON       NVARCHAR(MAX) = NULL
)
AS
  BEGIN
    UPDATE [@SCHEMA@].[Languages]
      SET     
       [ANSI Code Page] = @ANSI_Code_Page
     , [Culture] = @Culture
     , [DateTimeFormatJSON] = @DateTimeFormatJSON
     , [EBCDIC Code Page] = @EBCDIC_Code_Page
     , [English Name] = @English_Name
     , [InUse] = @InUse
     , [IsNeutralCulture] = @IsNeutralCulture
     , [LCID] = @LCID
     , [List Separator] = @List_Separator
     , [Local Name] = @Local_Name
     , [Mac Code Page] = @Mac_Code_Page
     , [NumberFormatJSON] = @NumberFormatJSON
     , [OEM Code Page] = @OEM_Code_Page
     , [RightToLeft] = @RightToLeft
     , [TextInfoJSON] = @TextInfoJSON
    WHERE 
           [Culture]
           = @Culture;
  END;
GO
/****** Object:  StoredProcedure [@SCHEMA@].[LanguagesByCountry_Delete]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [@SCHEMA@].[LanguagesByCountry_Delete]
(
   @Culture NVARCHAR(40) = NULL
 , @GeoId   INT          = NULL
)
AS
  BEGIN
    DELETE FROM [@SCHEMA@].[LanguagesByCountry]
    WHERE      
           [Culture]
           = @Culture
           AND [GeoId] = @GeoId;
  END; 
GO
/****** Object:  StoredProcedure [@SCHEMA@].[LanguagesByCountry_Insert]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [@SCHEMA@].[LanguagesByCountry_Insert]
(
   @Culture NVARCHAR(40) = NULL
 , @GeoId   INT          = NULL
 , @InUse   BIT
)
AS
  BEGIN
    INSERT INTO [@SCHEMA@].[LanguagesByCountry]
      (
       [Culture]
     , [GeoId]
     , [InUse]
      )
    VALUES
    (
      @Culture
    , @GeoId
    , @InUse
    );
  END;
GO
/****** Object:  StoredProcedure [@SCHEMA@].[LanguagesByCountry_Update]    Script Date: 21/08/2021 10:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [@SCHEMA@].[LanguagesByCountry_Update]
(
   @Culture NVARCHAR(40) = NULL
 , @GeoId   INT          = NULL
 , @InUse   BIT
)
AS
  BEGIN
    UPDATE [@SCHEMA@].[LanguagesByCountry]
      SET     
       [Culture] = @Culture
     , [GeoId] = @GeoId
     , [InUse] = @InUse
    WHERE 
           [Culture]
           = @Culture
           AND [GeoId] = @GeoId;
  END;
GO
