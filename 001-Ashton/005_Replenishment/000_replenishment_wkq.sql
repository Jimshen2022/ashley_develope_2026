
-- replenishment rules
SELECT replenishment_rule_id, description, sproc_name, rule_type
FROM dbo.t_replenishment_rule
ORDER BY replenishment_rule_id;

-- item 现有 open replen WKQ
SELECT work_q_id, work_type, pick_ref_number, item_number,
       location_id, from_location_id, qty, priority, work_status
FROM dbo.t_work_q WITH (NOLOCK)
WHERE wh_id = '335'
  AND work_type = '07'
  AND work_status <> 'C'
  AND pick_ref_number IN ('INTERBUILDING','REPLENISH','LTCREPLENISH')
  --AND item_number = 'D947-00'
ORDER BY work_q_id DESC;