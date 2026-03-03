/****** SupplyChain_Enh.ItemABCCode (WVF)  ******/

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
SELECT DISTINCT [Item SKU]
INTO #ItemLoc
FROM SupplyChain_Enh.ActualsCustItemWH_WVF
WHERE OrigReqWkEnding BETWEEN @StartDate AND @EndDate

-- Cross join week ending dates to all items
SELECT  I.[Item SKU]
		,#FWeeks.[Week Ending]
INTO #ItemLocWeeks  
FROM #FWeeks
CROSS JOIN #ItemLoc AS I 

-- Join ItemLocWeeks to actual orders. Set 'NULL' values to 0
SELECT I.[Item SKU],
       I.[Week Ending],
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
SELECT [Item SKU],
		OrigReqWkEnding,
		SUM([Order Quantity]) AS [QTY Ordered]
FROM SupplyChain_Enh.ActualsCustItemWH_WVF
WHERE OrigReqWkEnding BETWEEN @StartDate AND @EndDate
GROUP BY [Item SKU],
		OrigReqWkEnding
    ) AS OrdHist
        ON OrdHist.[Item SKU] = I.[Item SKU]
           AND OrdHist.OrigReqWkEnding = I.[Week Ending];


-- Get Average weekly Demand
SELECT [Item SKU],
       CAST(AVG([Qty Ordered]) AS DECIMAL(10, 4)) AS [Avg Wkly Demand],
       CAST(STDEVP([Qty Ordered]) AS DECIMAL(10, 4)) AS [Std Dev of Demand]
INTO #ItemAvg
FROM #OrdHist
GROUP BY [Item SKU]
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
                    END
INTO #coefv
FROM #ItemAvg 

-- Split Coefficient of Variation into three groups
SELECT [Item SKU],
	   [CoefVar],
	   NTILE(3) OVER (ORDER BY CoefVar) AS [XYZ]
INTO #XYZ
FROM #coefv

-- Calculate cumulative percent of demand for grouping ABC
SELECT [Item SKU],
       [Avg Wkly Demand],
       CAST(100 * SUM([Avg Wkly Demand]) OVER (ORDER BY [Avg Wkly Demand]) / SUM([Avg Wkly Demand]) OVER () AS NUMERIC(10, 2)) percentage
INTO #CumlPerc
FROM #ItemAvg;

DECLARE @MinA INT;
SET @MinA =
(
    SELECT TOP 1 [Avg Wkly Demand] FROM #CumlPerc ORDER BY ABS(percentage - 40) ASC
);
DECLARE @MinB INT;
SET @MinB =
(
    SELECT TOP 1 [Avg Wkly Demand] FROM #CumlPerc ORDER BY ABS(percentage - 20) ASC
);

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
							[Warehouse Group] = '232'

							
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
                            WHEN ABC.[Avg Wkly Demand] >= @MinA THEN
                                'A'
                            WHEN ABC.[Avg Wkly Demand] < @MinA
                                 AND ABC.[Avg Wkly Demand] >= @MinB THEN
                                'B'
                            ELSE
                                'C'
                        END,
           [XYZ Code] = CASE
                            WHEN ABC.[Manufacturing Status] = 'Discontinued' THEN
                                'Z'
                            -- Non-Invoiced Items priority sorted by Qty
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND ABC.[Avg Wkly Demand] >= @MinA THEN
                                'Z'
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND
                                 (
                                     ABC.[Avg Wkly Demand] < @MinA
                                     AND ABC.[Avg Wkly Demand] >= (@MinB - 20)
                                 ) THEN
                                'Y'
                            WHEN ABC.[Initial Invoice Period] IS NULL
                                 AND ABC.[Avg Wkly Demand] < @MinB THEN
                                'X'
                            -- Current and Invoiced items priority sorted by Coefficient of Variation
                            WHEN ABC.XYZ = 1 THEN
                                'X'
                            WHEN ABC.XYZ = 2 THEN
                                'Y'
                            ELSE
                                'Z'
                        END
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
			   FV.CoefVar
        FROM #ItemAvg AS IA
            LEFT JOIN #XYZ AS FV
                ON FV.[Item SKU] = IA.[Item SKU]
			LEFT JOIN PowerBI_SupplyChain.CurrentProductDetails_WVF AS C
				ON C.[Item SKU] = IA.[Item SKU]
) AS ABC
) AS FABC



		
DROP TABLE #FWeeks
DROP TABLE #ItemLoc
DROP TABLE #ItemLocWeeks
DROP TABLE #OrdHist
DROP TABLE #ItemAvg
DROP TABLE #coefv
DROP TABLE #XYZ
DROP TABLE #CumlPerc