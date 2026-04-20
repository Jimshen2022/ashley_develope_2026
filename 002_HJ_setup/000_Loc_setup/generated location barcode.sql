begin tran
declare @v_vchNewLocBarcode		AS NVARCHAR(20),
		@v_vchlocationID		as nvarchar(20)
select @v_vchNewLocBarcode='',@v_vchlocationID=''
select location_id,
		'N' as process_flag
into #temp_loc
from t_location (nolock)
--where left(location_id,5) between 'K6067' and 'K6067' and location_barcode is null
where location_id in ('K3074GA1',
'K3074GB1',
'K3074GC1',
'K3074GD1',
'K3074GE1',
'K3074GF1',
'K3074GG1',
'K3074GH1',
'K3074GJ1',
'K3074GK1',
'K3074GL1',
'K3074GM1',
'K3074GN1',
'K3074GP1',
'K3074GQ1',
'K3074GR1',
'K3074GS1',
'K3074GT1',
'K3074GU1',
'K3074GV1',
'K3074GW1',
'K3074GX1',
'K3074GY1',
'K3074GZ1')
order by location_id
LoopLOC:
select top 1 @v_vchlocationID = location_id
from #temp_loc (nolock)
where process_flag='N'
IF @@rowcount > 0
BEGIN
EXEC usp_Gen_Alt_HJ_Loc @v_vchNewLocBarcode OUTPUT
if not exists (select 1 from t_location (nolock) where location_barcode=@v_vchNewLocBarcode)
 begin
 update t_location
 set location_barcode=@v_vchNewLocBarcode
 where location_id=@v_vchlocationID
 end
 update #temp_loc
    set process_flag='Y'
  where location_id= @v_vchlocationID
 select @v_vchNewLocBarcode='',@v_vchlocationID=''
 goto LoopLOC
END
drop table #temp_loc
rollback tran