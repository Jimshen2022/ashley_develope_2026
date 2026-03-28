 

CREATE PROCEDURE [dbo].[usp_ww_search_by_serial_number]  
   @in_from_serial_number		VARCHAR(30)  
 , @in_to_serial_number			VARCHAR(30)
 , @in_item_number				VARCHAR(30)
 , @in_po_number				VARCHAR(30)
 , @in_location_id				VARCHAR(50)
 , @in_wh_id					VARCHAR(10)
 , @in_serial_status			VARCHAR(1)
 , @in_order_number				VARCHAR(20)
 , @in_hu_id					VARCHAR(22) = NULL
   
AS  
SET NOCOUNT ON  
  
DECLARE  
    -- Error handling and logging variables.  
    @c_nModuleNumber            INT, -- The # that uniquely tags the WA collection of objects.  
    @c_nFileNumber              INT, -- The # that uniquely tags this object.  
    @v_nLogErrorNum             INT, -- The # that uniquely tags the error message.   
    @v_nLogLevel                INT, -- Holds log level (1-5).  
    @v_vchErrorMsg              VARCHAR(500),  
    @v_nErrorNumber             INT ,

	--Local Variables.
	@v_vch_serial_hold			VARCHAR(1)
	-- Set Constants  
	SET @c_nModuleNumber = 60     -- Always #60 for WA.  
	SET @c_nFileNumber = 18       -- This # must be unique per object.  
		
BEGIN TRY  
	CREATE TABLE #Serial
	(
		serial_number      VARCHAR(30),
		m_serial_no_status VARCHAR(1),
		a_serial_no_status VARCHAR(1),
		m_owner_id         VARCHAR(10),
		i_cube				FLOAT
	)

	IF ISNULL(@in_from_serial_number,'') = ''
	   AND ISNULL(@in_to_serial_number,'') = ''
	   AND ( @in_item_number = '%' OR @in_item_number = '%%')
	   AND ( @in_location_id = '%' OR @in_location_id = '%%')
	   AND @in_po_number = '%'
	   AND @in_hu_id = '%'
  BEGIN
      SELECT 'You Must Enter Selection Criteria.' AS error
	  GOTO ExitLabel
  END
  
  SELECT @v_vch_serial_hold = CASE
                            WHEN @in_serial_status = 'H' THEN 'H'
                            ELSE NULL
							END

	
  IF @v_vch_serial_hold = 'H'
  BEGIN
    INSERT INTO #Serial
    SELECT sna.serial_number,
            snm.serial_no_status,
            sna.serial_no_status,
            snm.owner_id,
			ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube
    FROM dbo.t_serial_active sna (NOLOCK)
	JOIN dbo.t_item_master itm (NOLOCK)
		ON itm.item_number = sna.item_number
		AND itm.wh_id = sna.wh_id
		AND itm.commodity_code LIKE 'Z%'
	LEFT OUTER JOIN dbo.t_serial_master snm (NOLOCK)
		ON sna.serial_number = snm.serial_number
		AND sna.item_number = snm.item_number
		AND sna.wh_id = snm.wh_id
      WHERE  sna.wh_id LIKE @in_wh_id
        AND snm.serial_no_status = 'H'
  END

  IF ( @in_order_number != '%' )
  BEGIN
      SELECT m.wh_id,
             a.serial_number,
             a.item_number,
			 ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube,
             CASE
               WHEN a.serial_no_status = 'H' THEN 'Hold'
               WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
               WHEN a.serial_no_status = 'L' THEN 'Loaded'
               WHEN a.serial_no_status = 'S' THEN 'Shipped'
               WHEN a.serial_no_status = 'O' THEN 'Orphaned'
               ELSE NULL
             END AS serial_status,
             CASE
               WHEN m.serial_no_status = 'H' THEN 'Hold'
               WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
               WHEN m.serial_no_status = 'L' THEN 'Loaded'
               WHEN m.serial_no_status = 'S' THEN 'Shipped'
               WHEN m.serial_no_status = 'O' THEN 'Orphaned'
               ELSE NULL
             END AS master_status,
             CASE
               WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
               ELSE ''
             END AS po_number,
             m.po_number   AS master_po_number,
             a.location_id AS location,
             a.hu_id       AS LP,
             a.received_date,
             a.trip_number,
             CASE
               WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
              ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
             END AS ship_date,
             CASE
               WHEN m.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
               ELSE ISNULL(carb.description, m.carb_compliance_level)
             END AS carb_level,
             carb.rotation_sequence,
             m.born_on_date
      FROM   dbo.t_serial_active a (nolock)
             JOIN dbo.t_item_master itm (nolock)
				ON itm.item_number = a.item_number
                AND itm.wh_id = a.wh_id
                AND ( itm.commodity_code LIKE 'Z%'
					OR itm.commodity_code = 'TA' )
             LEFT OUTER JOIN dbo.t_serial_master m (nolock)
                ON a.serial_number = m.serial_number
                AND a.item_number = m.item_number
                AND a.wh_id = m.wh_id
             LEFT OUTER JOIN dbo.t_carb_master carb (nolock)
                ON carb.carb_compliance_level = m.carb_compliance_level
      WHERE  a.serial_number IN 
	  (
		SELECT DISTINCT sna.serial_number
        FROM dbo.t_order orm WITH (NOLOCK)
		INNER JOIN dbo.t_pick_detail pkd WITH (NOLOCK)
				ON orm.order_number = pkd.order_number
				AND orm.wh_id = pkd.wh_id
		INNER JOIN dbo.t_stored_item AS sto WITH (NOLOCK)
				ON sto.type = orm.order_number
				AND sto.item_number = pkd.item_number
				AND pkd.wh_id = sto.wh_id
        INNER JOIN dbo.t_serial_active AS sna WITH (NOLOCK)
                ON sna.location_id = sto.location_id
                AND sna.item_number = sto.item_number
                AND sna.serial_no_status = 'R'
                AND sto.wh_id = sna.wh_id
        INNER JOIN t_location AS loc WITH (NOLOCK)
                ON loc.location_id = sna.location_id
                AND loc.type = 'S'
                AND loc.wh_id = sna.wh_id
        WHERE  orm.type_id IN ( '24', '195', '196' )
            AND sto.item_number LIKE @in_item_number
            AND sto.type LIKE @in_order_number
	)
  END
  ELSE
	  IF @in_from_serial_number <> ''
	  BEGIN
		  IF @in_to_serial_number <> ''
			BEGIN
				SELECT m.wh_id,
					   a.serial_number,
					   a.item_number,
					   ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube,
					   CASE
						 WHEN a.serial_no_status = 'H' THEN 'Hold'
						 WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
						 WHEN a.serial_no_status = 'L' THEN 'Loaded'
						 WHEN a.serial_no_status = 'S' THEN 'Shipped'
						 WHEN a.serial_no_status = 'O' THEN 'Orphaned'
						 ELSE NULL
					   END AS serial_status,
					   CASE
						 WHEN m.serial_no_status = 'H' THEN 'Hold'
						 WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
						 WHEN m.serial_no_status = 'L' THEN 'Loaded'
						 WHEN m.serial_no_status = 'S' THEN 'Shipped'
						 WHEN m.serial_no_status = 'O' THEN 'Orphaned'
						 ELSE NULL
					   END AS master_status,
					   CASE
						 WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
						 ELSE ''
					   END AS po_number,
					   m.po_number   AS master_po_number,
					   a.location_id AS location,
					   a.hu_id       AS LP,
					   a.received_date,
					   a.trip_number,
					   CASE
						 WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
						 ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
					   END  AS ship_date,
					   CASE
						 WHEN m.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
						 ELSE ISNULL(carb.description, m.carb_compliance_level)
					   END AS carb_level,
					   carb.rotation_sequence,
					   m.born_on_date
				FROM dbo.t_serial_active a (NOLOCK)
				JOIN dbo.t_item_master itm (NOLOCK)
					ON itm.item_number = a.item_number
					AND itm.wh_id = a.wh_id
					AND ( itm.commodity_code LIKE 'Z%'
							OR itm.commodity_code = 'TA' )
				LEFT OUTER JOIN dbo.t_serial_master m (NOLOCK)
					ON a.serial_number = m.serial_number
					AND a.item_number = m.item_number
					AND a.wh_id = m.wh_id
				LEFT OUTER JOIN dbo.t_carb_master carb (NOLOCK)
					ON carb.carb_compliance_level = m.carb_compliance_level
				WHERE  a.serial_number >= @in_from_serial_number
					   AND a.serial_number <= @in_to_serial_number
					   AND a.wh_id LIKE @in_wh_id
					   AND ( ( @in_serial_status = 'H'
					   AND ISNULL(m.serial_no_status, 'R') = 'H' )
					   OR ISNULL(a.serial_no_status, 'R') LIKE @in_serial_status
					   AND ( ( @in_serial_status = 'R'
							AND ISNULL(a.serial_no_status, '?') IN ( 'R', 'H', 'L' ) )
							OR ( @in_serial_status = ISNULL(a.serial_no_status, 'R') )
							OR ( @in_serial_status = '%' ) ) )
			END
		  ELSE
			BEGIN
				SELECT 'You must specify a "TO" Serial Number criteria.' AS error
				GOTO ExitLabel
			END
	  END
	  ELSE IF @in_to_serial_number <> ''
	  BEGIN
		  IF @in_from_serial_number <> ''
		  BEGIN
				SELECT m.wh_id,
					   a.serial_number,
					   a.item_number,
					   ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube,
					   CASE
						 WHEN a.serial_no_status = 'H' THEN 'Hold'
						 WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
						 WHEN a.serial_no_status = 'L' THEN 'Loaded'
						 WHEN a.serial_no_status = 'S' THEN 'Shipped'
						 WHEN a.serial_no_status = 'O' THEN 'Orphaned'
						 ELSE NULL
					   END  AS serial_status,
					   CASE
						 WHEN m.serial_no_status = 'H' THEN 'Hold'
						 WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
						 WHEN m.serial_no_status = 'L' THEN 'Loaded'
						 WHEN m.serial_no_status = 'S' THEN 'Shipped'
						 WHEN m.serial_no_status = 'O' THEN 'Orphaned'
						 ELSE NULL
					   END  AS master_status,
					   CASE
						 WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
						 ELSE ''
					   END AS po_number,
					   m.po_number   AS master_po_number,
					   a.location_id AS location,
					   a.hu_id       AS LP,
					   a.received_date,
					   a.trip_number,
					   CASE
						 WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
						 ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
					   END  AS ship_date,
					   CASE
						 WHEN m.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
						 ELSE ISNULL(carb.description, m.carb_compliance_level)
					   END  AS carb_level,
					   carb.rotation_sequence,
					   m.born_on_date
				FROM dbo.t_serial_active a (NOLOCK)
				JOIN dbo.t_item_master itm (NOLOCK)
					ON itm.item_number = a.item_number
					AND itm.wh_id = a.wh_id
					AND ( itm.commodity_code LIKE 'Z%'
						OR itm.commodity_code = 'TA' )
				LEFT OUTER JOIN dbo.t_serial_master m (NOLOCK)
					ON a.serial_number = m.serial_number
					AND a.item_number = m.item_number
					AND a.wh_id = m.wh_id
				LEFT OUTER JOIN dbo.t_carb_master carb (NOLOCK)
					ON carb.carb_compliance_level = m.carb_compliance_level
				WHERE  a.serial_number >= @in_from_serial_number
					   AND a.serial_number <= @in_to_serial_number
					   AND a.wh_id LIKE @in_wh_id
					   AND ( ( @in_serial_status = 'H'
							AND ISNULL(m.serial_no_status, 'R') = 'H' )
					   OR ISNULL(a.serial_no_status, 'R') LIKE @in_serial_status
					   AND ( ( @in_serial_status = 'R'
							AND ISNULL(a.serial_no_status, '?') IN ( 'R', 'H', 'L' ) )
							OR ( @in_serial_status = ISNULL(a.serial_no_status, 'R') )
							OR ( @in_serial_status = '%' ) ) )
				END
				ELSE
				BEGIN
					SELECT 'You must specify a "FROM" Serial Number criteria.' AS error
					GOTO ExitLabel

				END
	  END
	  ELSE IF @in_po_number <> '%'
	  BEGIN
		  IF @in_item_number <> '%' AND @in_item_number <> '%%'
		  BEGIN
			SELECT m.wh_id,
					a.serial_number,
					a.item_number,
					ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube,
					CASE
						WHEN a.serial_no_status = 'H' THEN 'Hold'
						WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
						WHEN a.serial_no_status = 'L' THEN 'Loaded'
						WHEN a.serial_no_status = 'S' THEN 'Shipped'
						WHEN a.serial_no_status = 'O' THEN 'Orphaned'
						ELSE NULL
					END AS serial_status,
					CASE
						WHEN m.serial_no_status = 'H' THEN 'Hold'
						WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
						WHEN m.serial_no_status = 'L' THEN 'Loaded'
						WHEN m.serial_no_status = 'S' THEN 'Shipped'
						WHEN m.serial_no_status = 'O' THEN 'Orphaned'
						ELSE NULL
					END AS master_status,
					CASE
						WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
						ELSE ''
					END AS po_number,
					m.po_number   AS master_po_number,
					a.location_id AS location,
					a.hu_id       AS LP,
					a.received_date,
					a.trip_number,
					CASE
						WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
						ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
					END AS ship_date,
					CASE
						WHEN m.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
						ELSE ISNULL(carb.description, m.carb_compliance_level)
					END AS carb_level,
					carb.rotation_sequence,
					m.born_on_date
			FROM dbo.t_serial_active a (NOLOCK)
			JOIN dbo.t_item_master itm (NOLOCK)
				ON itm.item_number = a.item_number
				AND itm.wh_id = a.wh_id
				AND ( itm.commodity_code LIKE 'Z%'
						OR itm.commodity_code = 'TA' )
			LEFT OUTER JOIN dbo.t_serial_master m (NOLOCK)
				ON a.serial_number = m.serial_number
				AND a.item_number = m.item_number
				AND a.wh_id = m.wh_id
			LEFT OUTER JOIN dbo.t_carb_master carb (NOLOCK)
				ON carb.carb_compliance_level = m.carb_compliance_level
			WHERE ( a.po_number LIKE @in_po_number OR m.po_number LIKE @in_po_number )
				AND a.item_number LIKE @in_item_number
				AND a.wh_id LIKE @in_wh_id
				AND (( @in_serial_status = 'H' AND ISNULL(m.serial_no_status, 'R') = 'H' )
				OR ISNULL(a.serial_no_status, 'R') LIKE @in_serial_status
				AND (( @in_serial_status = 'R' AND ISNULL(a.serial_no_status, '?') IN ( 'R', 'H', 'L' ))
					OR ( @in_serial_status = ISNULL(a.serial_no_status, 'R') )
					OR ( @in_serial_status = '%' ) ) )
		END
		  ELSE
		  BEGIN
			SELECT 'You must enter an Item Number when specifying M Number.' AS error
			GOTO ExitLabel
		  END
	  END
	  ELSE IF @v_vch_serial_hold = 'H'
	  BEGIN
		IF @in_location_id = '%' OR @in_location_id = '%%'
        BEGIN
            SELECT a.wh_id,
                   h.serial_number,
                   a.item_number,
				   h.i_cube AS cube,
                   CASE
                     WHEN h.a_serial_no_status = 'H' THEN 'Hold'
                     WHEN ISNULL(h.a_serial_no_status, 'R') = 'R' THEN 'In Warehouse'
                     WHEN h.a_serial_no_status = 'L' THEN 'Loaded'
                     WHEN h.a_serial_no_status = 'S' THEN 'Shipped'
                     WHEN h.a_serial_no_status = 'O' THEN 'Orphaned'
                     ELSE NULL
                   END AS serial_status,
                   CASE
                     WHEN h.m_serial_no_status = 'H' THEN 'Hold'
                     WHEN ISNULL(h.m_serial_no_status, 'R') = 'R' THEN 'In Warehouse'
                     WHEN h.m_serial_no_status = 'L' THEN 'Loaded'
                     WHEN h.m_serial_no_status = 'S' THEN 'Shipped'
                     WHEN h.m_serial_no_status = 'O' THEN 'Orphaned'
                     ELSE NULL
                   END AS master_status,
                   CASE
                     WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
                     ELSE ''
                   END AS po_number,
                   m.po_number   AS master_po_number,
                   a.location_id AS location,
                   a.hu_id       AS LP,
                   a.received_date,
                   a.trip_number,
                   CASE
                     WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
                     ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
                   END AS ship_date,
                   CASE
                     WHEN h.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
                     ELSE ISNULL(carb.description, m.carb_compliance_level)
                   END AS carb_level,
                   carb.rotation_sequence,
                   m.born_on_date
            FROM dbo.t_serial_active a (NOLOCK)
            JOIN #Serial h
                ON a.serial_number = h.serial_number
            LEFT OUTER JOIN dbo.t_serial_master m (NOLOCK)
                ON a.serial_number = m.serial_number
            LEFT OUTER JOIN dbo.t_carb_master carb (NOLOCK)
                ON carb.carb_compliance_level = m.carb_compliance_level
            WHERE a.item_number LIKE @in_item_number 
                AND a.wh_id LIKE @in_wh_id
        END
      END
	  ELSE IF @in_item_number <> '%' AND @in_item_number <> '%%'
	  BEGIN
		IF @in_location_id = '%' OR @in_location_id = '%%'
        BEGIN
            SELECT m.wh_id,
                   a.serial_number,
                   a.item_number,
				   ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube,
                   CASE
                     WHEN a.serial_no_status = 'H' THEN 'Hold'
                     WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
                     WHEN a.serial_no_status = 'L' THEN 'Loaded'
                     WHEN a.serial_no_status = 'S' THEN 'Shipped'
                     WHEN a.serial_no_status = 'O' THEN 'Orphaned'
                     ELSE NULL
                   END AS serial_status,
                   CASE
                     WHEN m.serial_no_status = 'H' THEN 'Hold'
                     WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
                     WHEN m.serial_no_status = 'L' THEN 'Loaded'
                     WHEN m.serial_no_status = 'S' THEN 'Shipped'
                     WHEN m.serial_no_status = 'O' THEN 'Orphaned'
                     ELSE NULL
                   END AS master_status,
                   CASE
                     WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
                     ELSE ''
                   END AS po_number,
                   m.po_number   AS master_po_number,
                   a.location_id AS location,
                   a.hu_id       AS LP,
                   a.received_date,
                   a.trip_number,
                   CASE
                     WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
                     ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
                   END AS ship_date,
                   CASE
                     WHEN m.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
                     ELSE ISNULL(carb.description, m.carb_compliance_level)
                   END AS carb_level,
                   carb.rotation_sequence,
                   m.born_on_date
            FROM dbo.t_serial_active a (NOLOCK)
            JOIN dbo.t_item_master itm (NOLOCK)
                ON itm.item_number = a.item_number
                AND itm.wh_id = a.wh_id
                AND (itm.commodity_code LIKE 'Z%' OR itm.commodity_code = 'TA' )
            LEFT OUTER JOIN dbo.t_serial_master m (NOLOCK)
                ON a.serial_number = m.serial_number
                AND a.item_number = m.item_number
            LEFT OUTER JOIN dbo.t_carb_master carb (NOLOCK)
                ON carb.carb_compliance_level = m.carb_compliance_level
            WHERE  a.item_number LIKE @in_item_number
            AND a.wh_id LIKE @in_wh_id
            AND (( @in_serial_status = 'H'AND ISNULL(m.serial_no_status, 'R') = 'H' )
            OR ISNULL(a.serial_no_status, 'R') LIKE @in_serial_status
            AND (( @in_serial_status = 'R'AND ISNULL(a.serial_no_status, '?') IN ( 'R', 'H', 'L' ) )
				OR ( @in_serial_status = ISNULL(a.serial_no_status, 'R') )
				OR ( @in_serial_status = '%' ) ) )
        END
		ELSE
        BEGIN
            SELECT m.wh_id,
                   a.serial_number,
                   a.item_number,
				   ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube,
                   CASE
                     WHEN a.serial_no_status = 'H' THEN 'Hold'
                     WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
                     WHEN a.serial_no_status = 'L' THEN 'Loaded'
                     WHEN a.serial_no_status = 'S' THEN 'Shipped'
                     WHEN a.serial_no_status = 'O' THEN 'Orphaned'
                     ELSE NULL
                   END AS serial_status,
                   CASE
                     WHEN m.serial_no_status = 'H' THEN 'Hold'
                     WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
                     WHEN m.serial_no_status = 'L' THEN 'Loaded'
                     WHEN m.serial_no_status = 'S' THEN 'Shipped'
                     WHEN m.serial_no_status = 'O' THEN 'Orphaned'
                     ELSE NULL
                   END AS master_status,
                   CASE
                     WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
                     ELSE ''
                   END AS po_number,
                   m.po_number   AS master_po_number,
                   a.location_id AS location,
                   a.hu_id       AS LP,
                   a.received_date,
                   a.trip_number,
                   CASE
                     WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
                     ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
                   END AS ship_date,
                   CASE
                     WHEN m.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
                     ELSE ISNULL(carb.description, m.carb_compliance_level)
                   END AS carb_level,
                   carb.rotation_sequence,
                   m.born_on_date
            FROM dbo.t_serial_active a (nolock)
            JOIN dbo.t_item_master itm (nolock)
                ON itm.item_number = a.item_number
                AND itm.wh_id = a.wh_id
                AND ( itm.commodity_code LIKE 'Z%' OR itm.commodity_code = 'TA' )
            LEFT OUTER JOIN dbo.t_serial_master m (nolock)
                ON a.serial_number = m.serial_number
                AND a.item_number = m.item_number
                AND a.wh_id = m.wh_id
            LEFT OUTER JOIN dbo.t_carb_master carb (nolock)
                ON carb.carb_compliance_level = m.carb_compliance_level
            WHERE  a.item_number LIKE @in_item_number
                AND a.wh_id LIKE @in_wh_id
                AND (( @in_serial_status = 'H' AND ISNULL(m.serial_no_status, 'R') = 'H' )
                OR ISNULL(a.serial_no_status, 'R') LIKE @in_serial_status
                AND (( @in_serial_status = 'R' AND ISNULL(a.serial_no_status, '?') IN ( 'R', 'H', 'L' ) )
                    OR ( @in_serial_status = ISNULL(a.serial_no_status, 'R') )
                    OR ( @in_serial_status = '%' ) ) )
                AND a.location_id LIKE @in_location_id

        END
	  END
	  ELSE IF @in_location_id <> '%' AND @in_location_id <> '%%'
	  BEGIN
		  SELECT m.wh_id,
				 a.serial_number,
				 a.item_number,
				 ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube,
				 CASE
				   WHEN a.serial_no_status = 'H' THEN 'Hold'
				   WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
				   WHEN a.serial_no_status = 'L' THEN 'Loaded'
				   WHEN a.serial_no_status = 'S' THEN 'Shipped'
				   WHEN a.serial_no_status = 'O' THEN 'Orphaned'
				   ELSE NULL
				 END AS serial_status,
				 CASE
				   WHEN m.serial_no_status = 'H' THEN 'Hold'
				 WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
				   WHEN m.serial_no_status = 'L' THEN 'Loaded'
				   WHEN m.serial_no_status = 'S' THEN 'Shipped'
				   WHEN m.serial_no_status = 'O' THEN 'Orphaned'
				   ELSE NULL
				 END AS master_status,
				 CASE
				   WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
				   ELSE ''
				 END AS po_number,
				 m.po_number   AS master_po_number,
				 a.location_id AS location,
				 a.hu_id       AS LP,
				 a.received_date,
				 a.trip_number,
				 CASE
				   WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
				   ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
				 END AS ship_date,
				 CASE
				   WHEN m.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
				   ELSE ISNULL(carb.description, m.carb_compliance_level)
				 END AS carb_level,
				 carb.rotation_sequence,
				 m.born_on_date
		  FROM dbo.t_serial_active a (nolock)
		  JOIN dbo.t_item_master itm (nolock)
		    ON itm.item_number = a.item_number
			AND itm.wh_id = a.wh_id
			AND ( itm.commodity_code LIKE 'Z%'OR itm.commodity_code = 'TA' )
		  LEFT OUTER JOIN dbo.t_serial_master m (nolock)
			ON a.serial_number = m.serial_number
			AND a.item_number = m.item_number
			AND a.wh_id = m.wh_id
		LEFT OUTER JOIN dbo.t_carb_master carb (nolock)
			ON carb.carb_compliance_level = m.carb_compliance_level
		  WHERE  a.item_number LIKE @in_item_number
				 AND a.wh_id LIKE @in_wh_id
				 AND (( @in_serial_status = 'H'AND ISNULL(m.serial_no_status, 'R') = 'H' )
				 OR ISNULL(a.serial_no_status, 'R') LIKE @in_serial_status
				 AND (( @in_serial_status = 'R' AND ISNULL(a.serial_no_status, '?') IN ( 'R', 'H', 'L' ) )
					OR ( @in_serial_status = ISNULL(a.serial_no_status, 'R') )
					OR ( @in_serial_status = '%' ) ) )
				 AND a.location_id LIKE @in_location_id

	  END
	  ELSE IF @in_hu_id <> '%' AND @in_hu_id IS NOT NULL
	  BEGIN
			SELECT m.wh_id,
				 a.serial_number,
				 a.item_number,
				 ISNULL(itm.nested_volume,ISNULL(itm.unit_volume,0)) AS cube,
				 CASE
				   WHEN a.serial_no_status = 'H' THEN 'Hold'
				   WHEN ISNULL(a.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
				   WHEN a.serial_no_status = 'L' THEN 'Loaded'
				   WHEN a.serial_no_status = 'S' THEN 'Shipped'
				   WHEN a.serial_no_status = 'O' THEN 'Orphaned'
				   ELSE NULL
				 END AS serial_status,
				 CASE
				   WHEN m.serial_no_status = 'H' THEN 'Hold'
				   WHEN ISNULL(m.serial_no_status, 'R') = 'R' THEN 'In Warehouse'
				   WHEN m.serial_no_status = 'L' THEN 'Loaded'
				   WHEN m.serial_no_status = 'S' THEN 'Shipped'
				   WHEN m.serial_no_status = 'O' THEN 'Orphaned'
				   ELSE NULL
				 END AS master_status,
				 CASE
				   WHEN ISNULL(a.po_number, '') <> ISNULL(m.po_number, '') THEN ISNULL(a.po_number, '')
				   ELSE ''
				 END AS po_number,
				 m.po_number   AS master_po_number,
				 a.location_id AS location,
				 a.hu_id       AS LP,
				 a.received_date,
				 a.trip_number,
				 CASE
				   WHEN CONVERT(VARCHAR(23), a.ship_date, 121) = '1900-01-01 00:00:00.000' THEN ''
				   ELSE CONVERT(VARCHAR(23), a.ship_date, 121)
				 END AS ship_date,
				 CASE
				   WHEN m.serial_number IS NULL THEN 'MISSING SERIAL MASTER!'
				   ELSE ISNULL(carb.description, m.carb_compliance_level)
				 END AS carb_level,
				 carb.rotation_sequence,
				 m.born_on_date
		  FROM dbo.t_serial_active a (nolock)
		  JOIN dbo.t_item_master itm (nolock)
		    ON itm.item_number = a.item_number
			AND itm.wh_id = a.wh_id
			AND ( itm.commodity_code LIKE 'Z%'OR itm.commodity_code = 'TA' )
		  LEFT OUTER JOIN dbo.t_serial_master m (nolock)
			ON a.serial_number = m.serial_number
			AND a.item_number = m.item_number
			AND a.wh_id = m.wh_id
		  LEFT OUTER JOIN dbo.t_carb_master carb (nolock)
			ON carb.carb_compliance_level = m.carb_compliance_level
		  WHERE  a.hu_id LIKE @in_hu_id AND a.wh_id LIKE @in_wh_id
		  ORDER BY a.wh_id,a.hu_id,a.serial_number,a.item_number
	  END
END TRY

BEGIN CATCH

	SET @v_vchErrorMsg = ('|ERROR_PROCEDURE = '+ ISNULL(CAST(ERROR_PROCEDURE()	AS NVARCHAR),'')+ 
		'|ERROR_LINE = '+     ISNULL( CAST(ERROR_LINE()		AS NVARCHAR),'')+
		'|ERROR_MESSAGE = '+   ISNULL(CAST(ERROR_MESSAGE()		AS NVARCHAR(MAX)),'')
		) 	

	SELECT @v_nLogErrorNum = ERROR_NUMBER()

	SELECT @v_vchErrorMsg = REPLACE(@v_vchErrorMsg, '''', '''''')

	-- Log the error message in ADV..t_log_message
	EXECUTE dbo.usp_log_message @c_nModuleNumber
		,@c_nFileNumber
		,@v_nLogErrorNum
		,1
		,@v_vchErrorMsg
		,1   
END CATCH

ExitLabel:
  DROP TABLE #Serial

