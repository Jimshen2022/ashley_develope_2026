if '~status~' = 'NOLOSTHIS'
  BEGIN
	  SELECT DISTINCT trl.equipment_id,
                trl.status,
                trl.state,
                t_ya_location.location_name,
                t_trailer_type.trailer_type_name,
                c.carrier_name,
                CASE
                  WHEN ( ( wkq.type = '52'
                           AND wkq.status = 'UNASSIGNED' )
                          OR trl.status = 'IN YARD GROUND'
                          OR NOT EXISTS(SELECT 1
                                        FROM   t_control (nolock)
                                        WHERE  control_type = 'UNDIRECTED_YARD_MOVE'
                                               AND next_value = 1) ) THEN ''
                  ELSE 'GO TO'
                END                         AS move_loc,
                comments,
                tlm.load_id,
                ( CASE
                    WHEN t_ya_location.[type] = 'DRAYAGE' THEN NULL
                    ELSE 'Go To'
                  END )                     AS disposition_unit,
                wkq.zone,
                ytrn.[user_name]            AS scheduled_by,
                entered_yard,
                trl.exited_yard,
                T5.last_activity,
				T5.description, /*2019/06/31 Sonia Added*/
                trl.last_counted,
                awh.area_id,
                trl.trailer_id,
				trl.trailer_type_id,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple ASN'
                  ELSE a.load_number
                END                         AS commodity,
                com.commodity               AS outbound_commodity,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple ASN'
                  ELSE v.vendor_name
                END                         AS vendor_name,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple'
                  ELSE a.asn_number
                END                         AS asn_attached,
                trl.trailer_yard_tag,
                Isnull(ytrn.total_weight, 0)AS tare_weight,
				T5.disposition
FROM   t_trailer trl (NOLOCK)
       JOIN t_area_wh_id (NOLOCK) awh
       ON trl.area_id = awh.area_id
       LEFT OUTER JOIN (SELECT T98.trailer_id,
                               T98.[user_name]
                        FROM   t_ya_tran_log T98 (NOLOCK)
                        WHERE  T98.tran_type not in ('101B','103','424','522')
						AND T98.log_id = (SELECT Max(T100.log_id)
                                             FROM   t_ya_tran_log T100 (NOLOCK)
                                             WHERE  T98.trailer_id = T100.trailer_id
                                                    AND T100.tran_type = '300'
                                                    AND T100.area_name = '~area_id~')) T99
                    ON T99.trailer_id = trl.trailer_id
       LEFT OUTER JOIN (SELECT T2.trailer_id,
                               comments
                        FROM   t_trailer_comments(NOLOCK)
                               LEFT OUTER JOIN (SELECT trailer_id,
                                                       maxsequence = Max(sequence)
                                                FROM   t_trailer_comments(NOLOCK)
                                                GROUP  BY trailer_id) T2
                                            ON t_trailer_comments.trailer_id = T2.trailer_id
                                               AND t_trailer_comments.sequence = T2.maxsequence) T3
                    ON trl.trailer_id = T3.trailer_id
       LEFT OUTER JOIN (SELECT T4.carrier_trailer_number,
                               last_activity,description,case when tran_type='325' then control_number_2 else NULL end as disposition
                        FROM   t_ya_tran_log (NOLOCK)
                               LEFT OUTER JOIN (SELECT carrier_trailer_number,
                                                       last_activity = Max(ended)--(started)
                                                FROM   t_ya_tran_log (NOLOCK)
                                                WHERE  area_name = '~area_id~'
													AND tran_type not in ('101B','103','424','522')
                                                GROUP  BY carrier_trailer_number) T4
                                            ON t_ya_tran_log.carrier_trailer_number = T4.carrier_trailer_number
                                               AND t_ya_tran_log.ended/*.started*/ = T4.last_activity
											WHERE t_ya_tran_log.tran_type not in ('101B','103','424','522')) T5
                    ON trl.equipment_id = T5.carrier_trailer_number
       LEFT OUTER JOIN t_ya_work_q wkq (NOLOCK)
                    ON trl.trailer_id = wkq.trailer_id
                       AND wkq.status = 'UNASSIGNED'
                       AND wkq.type = '52'
					   AND wkq.area_id = awh.area_id
       LEFT OUTER JOIN t_carrier c (NOLOCK)
                    ON trl.carrier_id = c.carrier_id
       LEFT OUTER JOIN t_trailer_asn tasn (NOLOCK)
                    ON trl.trailer_id = tasn.trailer_id
       LEFT OUTER JOIN t_asn a (NOLOCK)
                    ON tasn.asn_id = a.asn_id
       LEFT JOIN t_vendor v (NOLOCK)
              ON a.vendor_id = v.vendor_id
       LEFT JOIN (SELECT trl2.trailer_id,
                         Count(*) AS 'asn_count'
                  FROM   t_trailer trl2 (nolock)
                         LEFT JOIN t_trailer_asn tra (nolock)
                                ON trl2.trailer_id = tra.trailer_id
                         LEFT JOIN t_asn asn (nolock)
                                ON tra.asn_id = asn.asn_id
                  WHERE  trl2.status != 'HISTORY'
                  GROUP  BY trl2.trailer_id) AS asn_count
              ON trl.trailer_id = asn_count.trailer_id
       LEFT OUTER JOIN t_trailer_commodity com (NOLOCK)
                    ON trl.trailer_id = com.trailer_id
       LEFT JOIN t_ya_tran_log ytrn
              ON ytrn.tran_type = '101'
                 AND trl.equipment_id = ytrn.carrier_trailer_number
                 AND ytrn.item_number IS NULL
                 AND ytrn.ended = trl.entered_yard
		--LEFT JOIN (SELECT DISTINCT control_number_2,control_number from dbo.t_ya_tran_log (NOLOCK)
		--	WHERE tran_type='325') ya
		--	ON ya.control_number = trl.equipment_id
         OUTER APPLY (SELECT TOP 1 tlm.load_id,
                                 tlm.equipment_id
                    FROM   t_load_master tlm (nolock)
                           JOIN t_trailer tlr (nolock)
                             ON tlm.equipment_id = tlr.equipment_id
                           JOIN t_ya_location yal (nolock)
                             ON tlr.location_id = yal.location_id
                    WHERE  tlr.status NOT IN ( 'HISTORY', 'LOST' )
                           AND ( tlr.state IN ( 'OUT PARTIA', 'OUT FULL' )
                                  OR ( yal.type = 'DOOR'
                                       AND tlr.state = 'EMPTY'
                                       AND tlm.status <> 'S' ) )
                           AND trl.equipment_id = tlm.equipment_id
                    ORDER  BY CASE
                                WHEN actual_ship_date IS NULL THEN trip_create_date
                                ELSE actual_ship_date
                              END DESC) AS tlm ,
       t_trailer_type (NOLOCK),
       t_ya_location (NOLOCK)
      WHERE  trl.equipment_id LIKE '~Equipment~'
             AND awh.area_id LIKE '~area_id~'
             AND location_name LIKE '~Location_Name~'
             AND Isnull(comments, '') LIKE '~comments~'
             AND trl.state LIKE '~state~'
             AND Isnull(t_trailer_type.trailer_type_name, '') LIKE '~trailer_type_name~'
             AND trl.location_id = t_ya_location.location_id
             AND t_trailer_type.trailer_type_id = trl.trailer_type_id
             AND trl.status NOT IN ( 'HISTORY', 'LOST' )
             AND c.carrier_name LIKE '~Carrier_Name~'
             AND ( isnull(a.load_number,'%') LIKE '~commodity~'
                    OR isnull(com.commodity,'%') LIKE '~commodity~' )
             AND Cast(Isnull(a.vendor_id, '') AS VARCHAR(10)) LIKE '~vendor~'
             AND trl.area_id = t_ya_location.area_id
			 AND 1 = CASE
                       WHEN Charindex('%', '~trailer_yard_tag~') > 0
                            AND Isnull(trl.trailer_yard_tag, '') LIKE '%' + '~trailer_yard_tag~' + '%' THEN 1
                       WHEN Isnull(trl.trailer_yard_tag, '') = '~trailer_yard_tag~' THEN 1
                       ELSE 0
                     END
      GROUP  BY trl.equipment_id,
                trl.state,
                t_ya_location.location_name,
                t_ya_location.[type],
                t_trailer_type.trailer_type_name,
                c.carrier_name,
                trl.status,
                wkq.status,
                wkq.type,
                comments,
                tlm.load_id,
                wkq.zone,
                ytrn.[user_name],
                trl.trailer_id,
                trl.entered_yard,
                trl.exited_yard,
                trl.last_counted,
                T5.last_activity,
				T5.description, /*2019/06/31 Sonia Added*/
                awh.area_id,
				trl.trailer_type_id,
                 CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple ASN'
                  ELSE a.load_number
                END,
                com.commodity,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple ASN'
                  ELSE v.vendor_name
                END,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple'
                  ELSE a.asn_number
                END,
                trl.trailer_yard_tag,
				ytrn.total_weight,
								T5.disposition

      ORDER  BY trl.equipment_id
  END
  ELSE
  BEGIN
      SELECT DISTINCT trl.equipment_id,
                trl.status,
                trl.state,
                t_ya_location.location_name,
                t_trailer_type.trailer_type_name,
                c.carrier_name,
                CASE
                  WHEN ( ( wkq.type = '52'
                           AND wkq.status = 'UNASSIGNED' )
                          OR trl.status = 'IN YARD GROUND'
                          OR NOT EXISTS(SELECT 1
                                        FROM   t_control (nolock)
                                        WHERE  control_type = 'UNDIRECTED_YARD_MOVE'
                                               AND next_value = 1) ) THEN ''
                  ELSE 'GO TO'
                END                         AS move_loc,
                comments,
                tlm.load_id,
                ( CASE
                    WHEN t_ya_location.[type] = 'DRAYAGE' THEN NULL
                    ELSE 'Go To'
                  END )                     AS disposition_unit,
                wkq.zone,
                ytrn.[user_name]            AS scheduled_by,
                entered_yard,
                trl.exited_yard,
                T5.last_activity,
				T5.description, /*2019/06/31 Sonia Added*/
                trl.last_counted,
                awh.area_id,
                trl.trailer_id,
				trl.trailer_type_id,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple ASN'
                  ELSE a.load_number
                END                         AS commodity,
                com.commodity               AS outbound_commodity,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple ASN'
                  ELSE v.vendor_name
                END                         AS vendor_name,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple'
                  ELSE a.asn_number
                END                         AS asn_attached,
                trl.trailer_yard_tag,
                Isnull(ytrn.total_weight, 0)AS tare_weight,
				T5.disposition
FROM   t_trailer trl (NOLOCK)
       JOIN t_area_wh_id (NOLOCK) awh
       ON trl.area_id = awh.area_id
       LEFT OUTER JOIN (SELECT T98.trailer_id,
                               T98.[user_name]
                        FROM   t_ya_tran_log T98 (NOLOCK)
                        WHERE  T98.log_id = (SELECT Max(T100.log_id)
                                             FROM   t_ya_tran_log T100 (NOLOCK)
                                             WHERE  T98.trailer_id = T100.trailer_id
                                                    AND T100.tran_type = '300'
                                                    AND T100.area_name = '~area_id~'
													AND T100.tran_type not in ('101B','103','424','522'))) T99
                    ON T99.trailer_id = trl.trailer_id
       LEFT OUTER JOIN (SELECT T2.trailer_id,
                               comments
                        FROM   t_trailer_comments(NOLOCK)
                               LEFT OUTER JOIN (SELECT trailer_id,
                                                       maxsequence = Max(sequence)
                                                FROM   t_trailer_comments(NOLOCK)
                                                GROUP  BY trailer_id) T2
                                            ON t_trailer_comments.trailer_id = T2.trailer_id
                                               AND t_trailer_comments.sequence = T2.maxsequence) T3
                    ON trl.trailer_id = T3.trailer_id
       LEFT OUTER JOIN (SELECT T4.carrier_trailer_number,
                               last_activity,description,case when tran_type='325' then control_number_2 else NULL end as disposition
                        FROM   t_ya_tran_log (NOLOCK)
                               LEFT OUTER JOIN (SELECT carrier_trailer_number,
                                                       last_activity = Max(ended)--(started)
                                                FROM   t_ya_tran_log (NOLOCK)
                                                WHERE  area_name ='~area_id~'
													AND tran_type not in ('101B','103','424','522')
                                                GROUP  BY carrier_trailer_number) T4
                                            ON t_ya_tran_log.carrier_trailer_number = T4.carrier_trailer_number
                                               AND t_ya_tran_log.ended/*.started*/ = T4.last_activity
											   AND t_ya_tran_log.tran_type not in ('101B','103','424','522')) T5
                    ON trl.equipment_id = T5.carrier_trailer_number
       LEFT OUTER JOIN t_ya_work_q wkq (NOLOCK)
                    ON trl.trailer_id = wkq.trailer_id
                       AND wkq.status = 'UNASSIGNED'
                       AND wkq.type = '52'
					   AND wkq.area_id = awh.area_id
       LEFT OUTER JOIN t_carrier c (NOLOCK)
                    ON trl.carrier_id = c.carrier_id
       LEFT OUTER JOIN t_trailer_asn tasn (NOLOCK)
                    ON trl.trailer_id = tasn.trailer_id
       LEFT OUTER JOIN t_asn a (NOLOCK)
                    ON tasn.asn_id = a.asn_id
       LEFT JOIN t_vendor v (NOLOCK)
              ON a.vendor_id = v.vendor_id
       LEFT JOIN (SELECT trl2.trailer_id,
                         Count(*) AS 'asn_count'
                  FROM   t_trailer trl2 (nolock)
                         LEFT JOIN t_trailer_asn tra (nolock)
                                ON trl2.trailer_id = tra.trailer_id
                         LEFT JOIN t_asn asn (nolock)
                                ON tra.asn_id = asn.asn_id
                  WHERE  trl2.status != 'HISTORY'
                  GROUP  BY trl2.trailer_id) AS asn_count
              ON trl.trailer_id = asn_count.trailer_id
       LEFT OUTER JOIN t_trailer_commodity com (NOLOCK)
                    ON trl.trailer_id = com.trailer_id
       LEFT JOIN t_ya_tran_log ytrn
              ON ytrn.tran_type = '101'
                 AND trl.equipment_id = ytrn.carrier_trailer_number
                 AND ytrn.item_number IS NULL
                 AND ytrn.ended = trl.entered_yard
			--			LEFT JOIN (SELECT DISTINCT control_number_2,control_number from dbo.t_ya_tran_log (NOLOCK)
			--WHERE tran_type='325') ya
			--ON ya.control_number = trl.equipment_id

         OUTER APPLY (SELECT TOP 1 tlm.load_id,
                                 tlm.equipment_id
                    FROM   t_load_master tlm (nolock)
                           JOIN t_trailer tlr (nolock)
                             ON tlm.equipment_id = tlr.equipment_id
                           JOIN t_ya_location yal (nolock)
                             ON tlr.location_id = yal.location_id
                    WHERE  tlr.status NOT IN ( 'HISTORY', 'LOST' )
                           AND ( tlr.state IN ( 'OUT PARTIA', 'OUT FULL' )
                                  OR ( yal.type = 'DOOR'
                                       AND tlr.state = 'EMPTY'
                                       AND tlm.status <> 'S' ) )
                           AND trl.equipment_id = tlm.equipment_id
                    ORDER  BY CASE
                                WHEN actual_ship_date IS NULL THEN trip_create_date
                                ELSE actual_ship_date
                              END DESC) AS tlm ,
       t_trailer_type (NOLOCK),
       t_ya_location (NOLOCK)
      WHERE  trl.equipment_id LIKE '~Equipment~'
             AND awh.area_id LIKE '~area_id~'
             AND location_name LIKE '~Location_Name~'
             AND Isnull(comments, '') LIKE '~comments~'
             AND trl.state LIKE '~state~'
             AND Isnull(t_trailer_type.trailer_type_name, '') LIKE '~trailer_type_name~'
             AND trl.location_id = t_ya_location.location_id
             AND t_trailer_type.trailer_type_id = trl.trailer_type_id
             AND trl.status LIKE'~status~'
             AND c.carrier_name LIKE '~Carrier_Name~'
             AND ( isnull(a.load_number,'%') LIKE '~commodity~'
                    OR isnull(com.commodity,'%') LIKE '~commodity~' )
             AND Cast(Isnull(a.vendor_id, '') AS VARCHAR(10)) LIKE '~vendor~'
             AND trl.area_id = t_ya_location.area_id
		      AND 1 = CASE
                       WHEN Charindex('%', '~trailer_yard_tag~') > 0
                            AND Isnull(trl.trailer_yard_tag, '') LIKE '%' + '~trailer_yard_tag~' + '%' THEN 1
                       WHEN Isnull(trl.trailer_yard_tag, '') = '~trailer_yard_tag~' THEN 1
                       ELSE 0
                     END
      GROUP  BY trl.equipment_id,
                trl.state,
                t_ya_location.location_name,
                t_ya_location.[type],
                t_trailer_type.trailer_type_name,
                c.carrier_name,
                trl.status,
                wkq.status,
                wkq.type,
                comments,
                tlm.load_id,
                wkq.zone,
                ytrn.[user_name],
                trl.trailer_id,
                trl.entered_yard,
                trl.exited_yard,
                trl.last_counted,
                T5.last_activity,
				T5.description, /*2019/06/31 Sonia Added*/
                awh.area_id,
				trl.trailer_type_id,
                 CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple ASN'
                  ELSE a.load_number
                END,
                com.commodity,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple ASN'
                  ELSE v.vendor_name
                END,
                CASE
                  WHEN asn_count.asn_count > 1 THEN 'Multiple'
                  ELSE a.asn_number
                END,
                trl.trailer_yard_tag,
				ytrn.total_weight,
				T5.disposition
      ORDER  BY trl.equipment_id
  END