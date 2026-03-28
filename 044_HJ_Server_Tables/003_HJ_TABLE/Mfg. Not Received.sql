
if '~Pick_Put_ID~'='UPH'
SELECT	 t_prod_receipt_upholstery.item_number  ,
       serial_number
       ,
       CONVERT(CHAR(10), expected_date, 111) + ' '
       + CONVERT(CHAR(8), expected_time, 108) AS expected_date
       ,
       mo_number,
       eol_scanned,
       born_on_date,
       carb_compliance_level
FROM   t_prod_receipt_upholstery(NOLOCK)
JOIN   t_item_master(NOLOCK) ON t_prod_receipt_upholstery.item_number = t_item_master.item_number
and t_prod_receipt_upholstery.wh_id=t_item_master.wh_id
      WHERE t_prod_receipt_upholstery.wh_id		LIKE '~WH_ID~'
       AND t_prod_receipt_upholstery.item_number	LIKE '~Item_Number~'
       AND received = 'N'
       AND eol_scanned = 'Y'
	   AND expected_date >= DATEADD(d, -60, GETDATE())
	   AND pick_put_id = 'UPH'

order by expected_date desc

else

SELECT	 t_prod_receipt_upholstery.item_number  ,
       serial_number
       ,
       CONVERT(CHAR(10), expected_date, 111) + ' '
       + CONVERT(CHAR(8), expected_time, 108) AS expected_date
      ,
       mo_number,
       eol_scanned,
       born_on_date,
       carb_compliance_level
FROM   t_prod_receipt_upholstery(NOLOCK)
JOIN   t_item_master(NOLOCK) ON t_prod_receipt_upholstery.item_number = t_item_master.item_number
and t_prod_receipt_upholstery.wh_id=t_item_master.wh_id
     
      WHERE t_prod_receipt_upholstery.wh_id		LIKE '~WH_ID~'
       AND t_prod_receipt_upholstery.item_number	LIKE '~Item_Number~'
       AND received = 'N'
       AND eol_scanned = 'Y'
	   AND expected_date >= DATEADD(d, -60, GETDATE())
	   AND pick_put_id <> 'UPH'	
order by expected_date desc
