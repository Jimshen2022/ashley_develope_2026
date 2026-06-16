-- wooden pallets
SELECT 
    year(transdate)*100+MONTH(transdate) AS year_month,
    itemnum, 
    description, 
    ponum,
    SUM(quantity) AS qty   
FROM Manufacturing_Maximo.Matrectrans 
WHERE issuetype = 'RECEIPT' 
    AND description LIKE 'WOODEN_PALLET%' 
    AND siteid = 'VNM.ASPM'
GROUP BY year(transdate)*100+MONTH(transdate), itemnum, description, ponum
ORDER BY year(transdate)*100+MONTH(transdate)