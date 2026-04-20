SELECT
    Serial,
    LastAddDateTime,
    CASE 
        WHEN To_Location IS NULL 
             OR LTRIM(RTRIM(To_Location)) = '' 
             OR To_Location = '000 0'
             OR REPLACE(To_Location, ' ', '') = '0000'
    THEN From_Location
    ELSE To_Location 
    END AS Current_Location,
    ScanCount
FROM (
    SELECT 
        t.Serial,
        CONVERT(DATETIME, 
            STUFF(STUFF(CAST(t.AddDate AS VARCHAR(8)), 5, 0, '-'), 8, 0, '-') + ' ' +
            STUFF(STUFF(RIGHT('000000' + CAST(t.AddTime AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
        ) AS LastAddDateTime,
        CONCAT(
            t.ToArea, 
            RIGHT('000' + CAST(t.ToAisle AS VARCHAR(3)), 3), 
            t.ToSection, 
            t.ToTier
        ) AS To_Location,
       CONCAT(
            t.FromArea, 
            RIGHT('000' + CAST(t.FromAisle AS VARCHAR(3)), 3), 
            t.FromSection, 
            t.FromTier
        ) AS From_Location,
        COUNT(*) OVER (PARTITION BY t.Serial) AS ScanCount,
        ROW_NUMBER() OVER (
            PARTITION BY t.Serial 
            ORDER BY t.AddDate DESC, t.AddTime DESC
        ) AS rn
    FROM Manufacturing_ProductionPlanning_MIL.ACTAUDT AS t
    WHERE t.Serial IS NOT NULL
        AND t.AddDate IS NOT NULL 
        AND t.AddTime IS NOT NULL
        AND t.Serial = '555636726090'  -- Example Serial filter
) AS ranked
WHERE rn = 1    
ORDER BY LastAddDateTime DESC