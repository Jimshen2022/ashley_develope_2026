SELECT 
    case when [From warehouse]='01' then '1'
	     when [From warehouse]='1' then '1'
		 when [From warehouse]='1-' then '1'
		 when [From warehouse]='1*' then '1'
	     when [From warehouse]='1.' then '1'
		 when [From warehouse]='1/' then '1'
		 when [From warehouse]='1\' then '1'
		 when [From warehouse]='/1' then '1'
		 when [From warehouse]='\1' then '1'
         else [From warehouse] end as [From warehouse]
       ,t1.[transaction date]
     ,Sum( t1.[Warehouse Damage Cost]) [Warehouse Damage Cost]
     , sum(t1.[Transfer Damage Cost]) [Transfer Damage Cost]
FROM [PowerBI_Distribution].[FactWarehouseDamages]    t1
    LEFT JOIN [PowerBI_Enterprise].[DimItemMaster] t2
        ON t1.[Item Number] = t2.ItemSKU
WHERE [Transaction date] BETWEEN DATEADD(day,-200,GETDATE()) AND GETDATE()
and t2.[sellableitemflag]='Y'
group by 
    [From warehouse]
       ,t1.[transaction date]