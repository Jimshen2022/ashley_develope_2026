-- =============================================
-- 1. 定义查询条件 (Define Query Parameters Here)
-- =============================================
DECLARE @Wh_Id TABLE (wh_id VARCHAR(50));
INSERT INTO @Wh_Id VALUES ('35'), ('31'), ('33'), ('36');

DECLARE @Load_Id VARCHAR(50)      = '%';     -- destination whse
DECLARE @Order_Number VARCHAR(50) = '%';

-- =============================================
-- 2. 主查询 (Main Query)
-- =============================================
SELECT 
    orm.wh_id,
    orm.order_number,
    ord.line_number,
    ord.item_number,
    itm.pick_put_id,
    orm.status,
    ord.qty,
    ord.qty_shipped,
    (ord.qty - ord.qty_shipped) AS diff_qty,
    
    -- 暂存数量 (Staged Qty)
    (SELECT SUM(sto1.actual_qty) 
     FROM t_stored_item sto1 WITH (NOLOCK) 
     WHERE sto1.wh_id = ord.wh_id 
       AND sto1.item_number = ord.item_number 
       AND sto1.type = ord.order_number 
       AND sto1.location_id IN (SELECT location_id FROM t_location WITH (NOLOCK) WHERE type = 'S')
    ) AS staged_qty,
    
    -- 装车数量 (Loaded Qty)
    (SELECT SUM(sto2.actual_qty) 
     FROM t_stored_item sto2 WITH (NOLOCK) 
     WHERE sto2.wh_id = ord.wh_id 
       AND sto2.item_number = ord.item_number 
       AND sto2.type = ord.order_number 
       AND sto2.location_id IN (SELECT location_id FROM t_location WITH (NOLOCK) WHERE type = 'D')
    ) AS loaded_qty,
    
    orm.load_id,

    -- ✅ 新增：来自 AD2055 的 transfer_whse_name（目标仓库名称）
    tlk.transfer_whse_name,

    -- ✅ 新增：到货日期 arrive_date（来自 t_order 主表）
    orm.arrive_date as ETD,

    ROUND(ISNULL(itm.nested_volume, itm.unit_volume), 2) AS unit_cube,
    ROUND((ISNULL(itm.nested_volume, itm.unit_volume) * (ord.qty - ord.qty_shipped)), 2) AS cube,
    
    -- 存储数量 (Storage Qty) -- 2021/12/06 Grace Liu add
    (SELECT SUM(actual_qty)  
     FROM t_stored_item sto WITH (NOLOCK) 
     WHERE sto.wh_id = ord.wh_id
       AND sto.item_number = ord.item_number
       AND sto.status = 'A'
       AND sto.type = 'STORAGE'
       AND sto.location_id IN (SELECT location_id FROM t_location WITH (NOLOCK) WHERE type IN ('A','M','I','X','P'))
     GROUP BY sto.wh_id, sto.item_number
    ) AS storage,
    
    -- 开放分配数量 (Open Allocation) -- 2021/12/06 Grace end
    (SELECT allocation_qty - allocated_qty 
     FROM t_soft_allocate_hotload allo WITH (NOLOCK) 
     WHERE allo.wh_id = orm.wh_id
       AND allo.item_number = ord.item_number
       AND allo.load_id = orm.load_id
    ) AS open_allocation

FROM t_order orm WITH (NOLOCK) 
JOIN t_order_detail ord WITH (NOLOCK) 
  ON orm.order_number = ord.order_number 
 AND orm.wh_id = ord.wh_id
JOIN t_lookup lok WITH (NOLOCK) 
  ON orm.type_id = lok.lookup_id 
 AND orm.wh_id = lok.wh_id 
 AND lok.locale_id = '1033'
JOIN t_item_master itm WITH (NOLOCK) 
  ON ord.wh_id = itm.wh_id 
 AND ord.item_number = itm.item_number

-- ✅ 新增：LEFT JOIN AD2055 的 transfer_whse_name 子查询
--    通过 order_number + wh_id 与主表匹配
LEFT JOIN (
    SELECT
        orm2.wh_id,
        orm2.order_number,
        orm2.load_id                                                        AS ad2055_load_id,
        (ISNULL(tlk2.description, '') + '(' + orm2.load_id + ')')          AS transfer_whse_name
    FROM dbo.t_order orm2 WITH (NOLOCK)
    JOIN dbo.t_lookup lok2 WITH (NOLOCK)
        ON  orm2.type_id   = lok2.lookup_id
        AND orm2.wh_id     = lok2.wh_id
        AND lok2.source    = 't_order'
        AND lok2.text      = 'HotLoad Orders'
        AND lok2.locale_id = '1033'
    LEFT JOIN dbo.t_lookup tlk2 WITH (NOLOCK)
        ON  orm2.load_id      = tlk2.text
        AND orm2.wh_id        = tlk2.wh_id
        AND tlk2.source       = 't_load_master'
        AND tlk2.lookup_type  = 'TRSFWHID'
        AND tlk2.locale_id    = '1033'
    WHERE orm2.wh_id IN (SELECT wh_id FROM @Wh_Id)
) tlk
  ON  tlk.wh_id        = orm.wh_id
  AND tlk.order_number = orm.order_number

WHERE 1=1
  -- 动态参数过滤 (Dynamic Parameter Filters)
  AND orm.wh_id  IN (SELECT wh_id FROM @Wh_Id) 
  AND orm.load_id LIKE @Load_Id 
  AND orm.order_number LIKE @Order_Number
  
  -- 固定业务逻辑过滤 (Static Business Logic Filters)
  AND lok.source = 't_order' 
  AND lok.text = 'HotLoad Orders' 
  AND orm.status NOT IN ('X','S','C')

ORDER BY 
    ord.order_number,
    ord.item_number;