SELECT
    [podordernum],
    [podvendornum],
    [podwarehouse],
    [podMfrName],
    [podMfrCountry],
    [poditemnum],
    [podqtyordered],
    [podstatuscode],
    [podduedate],
    [podcurrentprice],
    [podcubes],
    [podweight],
    CASE
        WHEN UPPER(LTRIM(RTRIM(podMfrCountry))) IN (
            'CHINA', 'JAPAN', 'SOUTH KOREA', 'NORTH KOREA', 'TAIWAN', 'HONG KONG',
            'MACAU', 'MONGOLIA', 'VIETNAM', 'THAILAND', 'MALAYSIA', 'SINGAPORE',
            'INDONESIA', 'PHILIPPINES', 'MYANMAR', 'LAOS', 'CAMBODIA'
        ) THEN 'Far East'

        WHEN UPPER(LTRIM(RTRIM(podMfrCountry))) IN (
            'UNITED KINGDOM', 'UK', 'GERMANY', 'FRANCE', 'ITALY', 'SPAIN', 'POLAND',
            'NETHERLANDS', 'BELGIUM', 'AUSTRIA', 'SWITZERLAND', 'SWEDEN', 'NORWAY',
            'FINLAND', 'DENMARK', 'IRELAND', 'PORTUGAL', 'GREECE', 'CZECH REPUBLIC',
            'HUNGARY', 'ROMANIA', 'BULGARIA', 'SLOVAKIA', 'SLOVENIA', 'UKRAINE',
            'RUSSIA', 'SERBIA', 'CROATIA', 'LITHUANIA', 'LATVIA', 'ESTONIA', 'ICELAND'
        ) THEN 'Europe'

        WHEN UPPER(LTRIM(RTRIM(podMfrCountry))) IN (
            'SAUDI ARABIA', 'UNITED ARAB EMIRATES', 'UAE', 'ISRAEL', 'QATAR', 'KUWAIT',
            'BAHRAIN', 'OMAN', 'JORDAN', 'LEBANON', 'SYRIA', 'IRAQ', 'IRAN', 'YEMEN', 'PALESTINE'
        ) THEN 'Middle East'

        WHEN UPPER(LTRIM(RTRIM(podMfrCountry))) IN (
            'BRAZIL', 'ARGENTINA', 'CHILE', 'PERU', 'COLOMBIA', 'ECUADOR', 'BOLIVIA',
            'PARAGUAY', 'URUGUAY', 'VENEZUELA', 'GUYANA', 'SURINAME'
        ) THEN 'South America'

        WHEN UPPER(LTRIM(RTRIM(podMfrCountry))) IN (
            'UNITED STATES', 'USA', 'CANADA', 'MEXICO', 'GREENLAND', 'BERMUDA', 'BAHAMAS',
            'CUBA', 'JAMAICA', 'DOMINICAN REPUBLIC', 'HAITI', 'GUATEMALA', 'HONDURAS',
            'EL SALVADOR', 'NICARAGUA', 'COSTA RICA', 'PANAMA'
        ) THEN 'North America'

        ELSE 'Africa / Other'
    END AS podRegion
FROM [Wholesale_ProductSourcing_AFI].[PoDetail]
WHERE
    podwarehouse = '335'
--     AND podstatuscode NOT IN ('10','20','30')
    AND podduedate > '2021-01-01'
    AND podMfrName IS NOT NULL
    AND LTRIM(RTRIM(podMfrName)) <> ''
ORDER BY [podduedate];


