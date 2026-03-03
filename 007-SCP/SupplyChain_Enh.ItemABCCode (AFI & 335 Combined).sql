/****** SupplyChain_Enh.ItemABCCode (AFI & 335 combined)  ******/

-- Declare Snapshot
	DECLARE @SnapshotMonthYear INT
	SET @SnapshotMonthYear = (SELECT [FiscalMonthYear] FROM [Enterprise_DW].[DimDate] WHERE [DateID] = CONVERT(DATE,GETDATE()))

-- Get Week ending date for last completed week
	DECLARE @EndDate date
	SET @EndDate = (SELECT DATEADD(DAY, -DATEPART(WEEKDAY, GETDATE()), GETDATE()))



-- Get week ending for 25 weeks before. (Last 26 completed weeks) 
	DECLARE @StartDate date
	SET @StartDate = DATEADD(WEEK,-25,@EndDate)



-- Get all week ending in past 26 weeks
SELECT DISTINCT CONVERT(Date, D.FiscalWeekLastDate) AS [Week Ending]
INTO #FWeeks
  FROM [Enterprise_DW].[DimDate] AS D
	WHERE D.FiscalWeekLastDate BETWEEN @StartDate AND @EndDate

	
-- Get all distinct Items from orders in last 26 weeks. 
SELECT DISTINCT I.[Item SKU]
      ,I.[Warehouse Group]
INTO #ItemLoc
FROM (
SELECT DISTINCT [Item SKU]
      ,[Warehouse Group] = 'AFI'
FROM SupplyChain_Enh.ActualsCustItemWH_AFI    
WHERE OrigReqWkEnding BETWEEN @StartDate AND @EndDate
	  AND Warehouse IN ('5', '28', 'ECR', '1', '3','12','15', '42', '17','16', '19')

UNION 

SELECT DISTINCT [Item SKU]
      ,[Warehouse Group] = '335'
FROM SupplyChain_Enh.ActualsCustItemWH_AFI
WHERE OrigReqWkEnding BETWEEN @StartDate AND @EndDate
	  AND Warehouse = '335'
) AS I

-- Cross join week ending dates to all item combinations
SELECT  I.[Item SKU]
		,#FWeeks.[Week Ending]
        ,[I].[Warehouse Group]
INTO #ItemLocWeeks  
FROM #FWeeks
CROSS JOIN #ItemLoc AS I 


-- Join ItemLocWeeks to actual orders. Set 'NULL' values to 0
SELECT I.[Item SKU],
       I.[Week Ending],
	   I.[Warehouse Group],
       [Qty Ordered] = CASE
                           WHEN OrdHist.[QTY Ordered] IS NULL THEN
                               0
                           WHEN OrdHist.[QTY Ordered] < 0 THEN
                               0
                           ELSE
                               OrdHist.[QTY Ordered]
                       END
INTO #OrdHist
  FROM #ItemLocWeeks AS I
    LEFT JOIN
    (
		SELECT [Item SKU]
				,OrigReqWkEnding
				,SUM([Order Quantity]) AS [QTY Ordered]
				,[Warehouse Group] = 'AFI'
		  FROM SupplyChain_Enh.ActualsCustItemWH_AFI
		    WHERE OrigReqWkEnding BETWEEN @StartDate AND @EndDate
	          AND Warehouse IN ('5', '28', 'ECR', '1', '3','12','15', '42', '17','16', '19')
		    GROUP BY [Item SKU],
		        OrigReqWkEnding

	UNION 
		SELECT [Item SKU]
				,OrigReqWkEnding
				,SUM([Order Quantity]) AS [QTY Ordered]
				,[Warehouse Group] = '335'
		  FROM SupplyChain_Enh.ActualsCustItemWH_AFI
		    WHERE OrigReqWkEnding BETWEEN @StartDate AND @EndDate
	          AND Warehouse = '335'
		    GROUP BY [Item SKU],
		        OrigReqWkEnding
    ) AS OrdHist
        ON OrdHist.[Item SKU] = I.[Item SKU]
           AND OrdHist.OrigReqWkEnding = I.[Week Ending]
		   AND [OrdHist].[Warehouse Group] = [I].[Warehouse Group];


-- Get Average weekly Demand
SELECT [Item SKU],
       --,Warehouse
       CAST(AVG([Qty Ordered]) AS DECIMAL(10, 4)) AS [Avg Wkly Demand],
       CAST(STDEVP([Qty Ordered]) AS DECIMAL(10, 4)) AS [Std Dev of Demand],
	   [Warehouse Group]
INTO #ItemAvg
  FROM #OrdHist
	GROUP BY [Warehouse Group], [Item SKU]
	HAVING CAST(AVG([Qty Ordered]) AS DECIMAL(10, 4)) > 0


-- Caculate Coefficient of Variation
SELECT [Item SKU],
       [Avg Wkly Demand],
       [Std Dev of Demand],
       [CoefVar] = CASE
                       WHEN [Std Dev of Demand] = 0 THEN
                            0
                       ELSE
                            CAST(([Std Dev of Demand] / [Avg Wkly Demand]) AS DECIMAL(10, 4))
                    END,
	  [Warehouse Group]
INTO #coefv
  FROM #ItemAvg 


-- Split Coefficient of Variation into three groups
SELECT C.[Item SKU],
	   C.[CoefVar],
	   C.[XYZ],
	   C.[Warehouse Group]
INTO #XYZ
  FROM (

  SELECT [Item SKU],
	   [CoefVar],
	   NTILE(3) OVER (ORDER BY CoefVar) AS [XYZ],
	   [Warehouse Group]
  FROM #coefv
   WHERE [Warehouse Group] = 'AFI'

UNION

  SELECT [Item SKU],
	   [CoefVar],
	   NTILE(3) OVER (ORDER BY CoefVar) AS [XYZ],
	   [Warehouse Group]
  FROM #coefv
   WHERE [Warehouse Group] = '335'

  ) AS C


-- Calculate cumulative percent of demand for grouping ABC
SELECT [Item SKU],
       [Avg Wkly Demand],
	   [Warehouse Group], 
       CAST(100 * SUM([Avg Wkly Demand]) OVER (ORDER BY [Avg Wkly Demand]) / SUM([Avg Wkly Demand]) OVER () AS NUMERIC(10, 2)) percentage
INTO #CumlPercAFI
  FROM #ItemAvg
  WHERE [Warehouse Group] = 'AFI';

DECLARE @MinAAFI INT;
SET @MinAAFI =
(
    SELECT TOP 1 [Avg Wkly Demand] FROM #CumlPercAFI ORDER BY ABS(percentage - 40) ASC
);
DECLARE @MinBAFI INT;
SET @MinBAFI =
(
    SELECT TOP 1 [Avg Wkly Demand] FROM #CumlPercAFI ORDER BY ABS(percentage - 20) ASC
);

-- Calculate cumulative percent of demand for grouping ABC
SELECT [Item SKU],
       [Avg Wkly Demand],
	   [Warehouse Group],
       CAST(100 * SUM([Avg Wkly Demand]) OVER (ORDER BY [Avg Wkly Demand]) / SUM([Avg Wkly Demand]) OVER () AS NUMERIC(10, 2)) percentage
INTO #CumlPerc335
  FROM #ItemAvg
  WHERE [Warehouse Group] = '335';

DECLARE @MinA335 INT;
SET @MinA335 =
(
    SELECT TOP 1 [Avg Wkly Demand] FROM #CumlPerc335 ORDER BY ABS(percentage - 40) ASC
);
DECLARE @MinB335 INT;
SET @MinB335 =
(
    SELECT TOP 1 [Avg Wkly Demand] FROM #CumlPerc335 ORDER BY ABS(percentage - 20) ASC
);



-- Final Output Table
SELECT FABC.[Item SKU],
       FABC.[Current Status],
       FABC.[Future Status],
       FABC.[Manufacturing Status],
       FABC.[Initial Invoice Period],
       FABC.[Import/Domestic Code],
       FABC.[Avg Wkly Demand],
       FABC.[Std Dev of Demand],
	   FABC.CoefVar,
       FABC.[ABC Code],
       FABC.[XYZ Code],
       [ABCXYZ Code] = CONCAT(FABC.[ABC Code], FABC.[XYZ Code]),
       [ABC Logility] = CASE
                            WHEN FABC.[Manufacturing Status] = 'Discontinued' THEN
                                'F'
                            WHEN FABC.[Initial Invoice Period] IS NULL THEN
                                'J'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'AX', 'AY' ) THEN
                                'A'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'AZ', 'BX' ) THEN
                                'B'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'BY', 'BZ' ) THEN
                                'C'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'CX', 'CY' ) THEN
                                'D'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'CZ' THEN
                                'E'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'DZ' THEN
                                'F'
                            ELSE
                                'N/A'
                        END,
       [ForecastPriority] = CASE
                                WHEN FABC.[Manufacturing Status] = 'Discontinued' THEN
                                    'Discontinued'
                                WHEN FABC.[Initial Invoice Period] IS NULL
                                     AND FABC.[XYZ Code] IN ( 'Y', 'Z' ) THEN
                                    CONCAT('High Priority ', FABC.[ABC Code])
                                WHEN FABC.[Initial Invoice Period] IS NULL
                                     AND FABC.[XYZ Code] = ('X') THEN
                                    CONCAT('Low Priority ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'AX' THEN
                                    CONCAT('Stable ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'AY', 'AZ' ) THEN
                                    CONCAT('High Priority ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'BX' THEN
                                    CONCAT('Stable ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'BY', 'BZ' ) THEN
                                    CONCAT('High Priority ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'CX' THEN
                                    CONCAT('Stable ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'CY', 'CZ' ) THEN
                                    CONCAT('Low Priority ', FABC.[ABC Code])
                                ELSE
                                    'N/A'
                            END,
       [SnapshotMonthYear] = @SnapshotMonthYear,
       FABC.[Warehouse Group]

							
FROM
(
SELECT ABC.[Item SKU],
           ABC.[Current Status],
           ABC.[Future Status],
           ABC.[Manufacturing Status],
           ABC.[Initial Invoice Period],
           ABC.[Import/Domestic Code],
           ABC.[Avg Wkly Demand],
           ABC.[Std Dev of Demand],
		   ABC.CoefVar,
		   ABC.XYZ,
           [ABC Code] = CASE
                            WHEN ABC.[Manufacturing Status] = 'Discontinued' THEN
                                'D'
                            WHEN ABC.[Initial Invoice Period] IS NULL THEN
                                'J'
                            WHEN ABC.[Avg Wkly Demand] >= @MinAAFI THEN
                                'A'
                            WHEN ABC.[Avg Wkly Demand] < @MinAAFI
                                 AND ABC.[Avg Wkly Demand] >= @MinBAFI THEN
                                'B'
                            ELSE
                                'C'
                        END,
           [XYZ Code] = CASE
                            WHEN ABC.[Manufacturing Status] = 'Discontinued' THEN
                                'Z'
                            -- Non-Invoiced Items priority sorted by Qty
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND ABC.[Avg Wkly Demand] >= @MinAAFI THEN
                                'Z'
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND
                                 (
                                     ABC.[Avg Wkly Demand] < @MinAAFI
                                     AND ABC.[Avg Wkly Demand] >= (@MinBAFI - 20)
                                 ) THEN
                                'Y'
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND ABC.[Avg Wkly Demand] < @MinBAFI THEN
                                'X'
                            -- Current and Invoiced items priority sorted by Coefficient of Variation
                            WHEN ABC.XYZ = 1 THEN
                                'X'
                            WHEN ABC.XYZ = 2 THEN
                                'Y'
                            ELSE
                                'Z'
                        END,
		 [ABC].[Warehouse Group]
    FROM
 (SELECT IA.[Item SKU],
               C.[Current Status],
               C.[Future Status],
               C.[Manufacturing Status],
               C.[Initial Invoice Period],
               C.[Import/Domestic Code],
               IA.[Avg Wkly Demand],
               IA.[Std Dev of Demand],
			   FV.XYZ,
			   FV.CoefVar,
			   [FV].[Warehouse Group]
        FROM #ItemAvg AS IA
            LEFT JOIN #XYZ AS FV
                ON FV.[Item SKU] = IA.[Item SKU]
				AND [IA].[Warehouse Group] = [FV].[Warehouse Group]
			LEFT JOIN PowerBI_SupplyChain.CurrentProductDetails AS C
				ON C.[Item SKU] = IA.[Item SKU]
		WHERE [IA].[Warehouse Group] = 'AFI'
		
) AS ABC
) AS FABC

UNION

SELECT FABC.[Item SKU],
       FABC.[Current Status],
       FABC.[Future Status],
       FABC.[Manufacturing Status],
       FABC.[Initial Invoice Period],
       FABC.[Import/Domestic Code],
       FABC.[Avg Wkly Demand],
       FABC.[Std Dev of Demand],
	   FABC.CoefVar,
       FABC.[ABC Code],
       FABC.[XYZ Code],
       [ABCXYZ Code] = CONCAT(FABC.[ABC Code], FABC.[XYZ Code]),
       [ABC Logility] = CASE
                            WHEN FABC.[Manufacturing Status] = 'Discontinued' THEN
                                'F'
                            WHEN FABC.[Initial Invoice Period] IS NULL THEN
                                'J'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'AX', 'AY' ) THEN
                                'A'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'AZ', 'BX' ) THEN
                                'B'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'BY', 'BZ' ) THEN
                                'C'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'CX', 'CY' ) THEN
                                'D'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'CZ' THEN
                                'E'
                            WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'DZ' THEN
                                'F'
                            ELSE
                                'N/A'
                        END,
       [ForecastPriority] = CASE
                                WHEN FABC.[Manufacturing Status] = 'Discontinued' THEN
                                    'Discontinued'
                                WHEN FABC.[Initial Invoice Period] IS NULL
                                     AND FABC.[XYZ Code] IN ( 'Y', 'Z' ) THEN
                                    CONCAT('High Priority ', FABC.[ABC Code])
                                WHEN FABC.[Initial Invoice Period] IS NULL
                                     AND FABC.[XYZ Code] = ('X') THEN
                                    CONCAT('Low Priority ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'AX' THEN
                                    CONCAT('Stable ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'AY', 'AZ' ) THEN
                                    CONCAT('High Priority ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'BX' THEN
                                    CONCAT('Stable ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'BY', 'BZ' ) THEN
                                    CONCAT('High Priority ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) = 'CX' THEN
                                    CONCAT('Stable ', FABC.[ABC Code])
                                WHEN CONCAT(FABC.[ABC Code], FABC.[XYZ Code]) IN ( 'CY', 'CZ' ) THEN
                                    CONCAT('Low Priority ', FABC.[ABC Code])
                                ELSE
                                    'N/A'
                            END,
       [SnapshotMonthYear] = @SnapshotMonthYear,
       FABC.[Warehouse Group]

							
FROM
(
SELECT ABC.[Item SKU],
           ABC.[Current Status],
           ABC.[Future Status],
           ABC.[Manufacturing Status],
           ABC.[Initial Invoice Period],
           ABC.[Import/Domestic Code],
           ABC.[Avg Wkly Demand],
           ABC.[Std Dev of Demand],
		   ABC.CoefVar,
		   ABC.XYZ,
           [ABC Code] = CASE
                            WHEN ABC.[Manufacturing Status] = 'Discontinued' THEN
                                'D'
                            WHEN ABC.[Initial Invoice Period] IS NULL THEN
                                'J'
                            WHEN ABC.[Avg Wkly Demand] >= @MinA335 THEN
                                'A'
                            WHEN ABC.[Avg Wkly Demand] < @MinA335
                                 AND ABC.[Avg Wkly Demand] >= @MinB335 THEN
                                'B'
                            ELSE
                                'C'
                        END,
           [XYZ Code] = CASE
                            WHEN ABC.[Manufacturing Status] = 'Discontinued' THEN
                                'Z'
                            -- Non-Invoiced Items priority sorted by Qty
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND ABC.[Avg Wkly Demand] >= @MinA335 THEN
                                'Z'
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND
                                 (
                                     ABC.[Avg Wkly Demand] < @MinA335
                                     AND ABC.[Avg Wkly Demand] >= (@MinB335 - 20)
                                 ) THEN
                                'Y'
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND ABC.[Avg Wkly Demand] < @MinB335 THEN
                                'X'
                            -- Current and Invoiced items priority sorted by Coefficient of Variation
                            WHEN ABC.XYZ = 1 THEN
                                'X'
                            WHEN ABC.XYZ = 2 THEN
                                'Y'
                            ELSE
                                'Z'
                        END,
		 [ABC].[Warehouse Group]
    FROM
 (SELECT IA.[Item SKU],
               C.[Current Status],
               C.[Future Status],
               C.[Manufacturing Status],
               C.[Initial Invoice Period],
               C.[Import/Domestic Code],
               IA.[Avg Wkly Demand],
               IA.[Std Dev of Demand],
			   FV.XYZ,
			   FV.CoefVar,
			   [FV].[Warehouse Group]
        FROM #ItemAvg AS IA
            LEFT JOIN #XYZ AS FV
                ON FV.[Item SKU] = IA.[Item SKU]
				AND [IA].[Warehouse Group] = [FV].[Warehouse Group]
			LEFT JOIN PowerBI_SupplyChain.CurrentProductDetails AS C
				ON C.[Item SKU] = IA.[Item SKU]
		WHERE [IA].[Warehouse Group] = '335'
		
) AS ABC
) AS FABC


		
DROP TABLE #FWeeks
DROP TABLE #ItemLoc
DROP TABLE #ItemLocWeeks
DROP TABLE #OrdHist
DROP TABLE #ItemAvg
DROP TABLE #coefv
DROP TABLE #XYZ
DROP TABLE #CumlPercAFI
DROP TABLE #CumlPerc335
