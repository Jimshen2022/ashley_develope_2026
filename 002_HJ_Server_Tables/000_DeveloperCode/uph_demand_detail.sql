/*
UPH positive forecast-demand detail rows behind the balance report.

Rules:
- item scope: dbo.t_item_master.pick_put_id = @pick_put_id
- demand source: dbo.t_item_forecast_daily
- only rows where forecast_demand > 0
*/

DECLARE @wh_id VARCHAR(10) = '335';
DECLARE @pick_put_id VARCHAR(15) = 'UPH';

SELECT
    f.wh_id,
    f.item_number,
    itm.description,
    itm.pick_put_id,
    itm.class_id,
    f.pick_day,
    f.forecast_demand
FROM dbo.t_item_forecast_daily f WITH (NOLOCK)
INNER JOIN dbo.t_item_master itm WITH (NOLOCK)
    ON itm.wh_id = f.wh_id
   AND itm.item_number = f.item_number
WHERE f.wh_id = @wh_id
  AND itm.pick_put_id = @pick_put_id
  AND f.forecast_demand > 0
ORDER BY
    f.item_number,
    f.pick_day;
