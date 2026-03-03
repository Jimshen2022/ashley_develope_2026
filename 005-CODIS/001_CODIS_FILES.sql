select top 10 * from Wholesale_CODIS.BTTRIPH AS t1
select  * from Wholesale_CODIS.ATOFILE as t1 WHERE t1.HOUS IN ('335')



select top 10 * from Wholesale_CODIS.ATOFILE as t1 and t1.HOUS IN ('335')
select top 10 * from Wholesale_CODIS.STDTRM as t1 

select top 10 * from Wholesale_CODIS.EXTORIT as t1 
select top 10 * from  Wholesale_CODIS.CODATAN as t1
select top 10 * from  Wholesale_CODIS.EXTORD as t1

select top 10 * from  Wholesale_CODIS_AFI.ESCHJTRK as t1 where t1.ETWarehouse in ('335')

select  * from  Wholesale_CODIS.RIMSRESD as t1 where t1.[Initial Station ID] in ('335') and t1.[Rimms Resource ID] in ('0032184','0040646','0032873')

select   * from   Distribution_Warehouse_Wholesale.LoadDispatch as t1 where t1.WhId in ('335') and t1.[LoadId] in ('0032184','0040646','0032873')
select   * from   Distribution_Warehouse_Wholesale.LoadMaster as t1 where t1.wh_id in ('335')  and t1.load_id in ('0032184','0040646','0032873')
select   * from Distribution_Warehouse_Wholesale.t_order as t1 where t1.wh_id in ('335')  and t1.load_id in ('0032184','0040646','0032873')
select  * from  Distribution_Warehouse_Wholesale.TripReport as t1 where t1.WhID in ('335')  and t1.LoadID in ('0032184-00','0040646-00','0032873-00')


/*
select top 10 * from Wholesale_CODIS.STDTRM as t1 
Wholesale_CODIS.ACNLORD
Wholesale_CODIS.WHFILRQ
Wholesale_CODIS.AshleyWarehouseMaster
select top 10 * from Wholesale_CODIS.EXTORIT as t1 
Wholesale_CODIS.POFirmComparison
Wholesale_CODIS.ATOFILE
Wholesale_CODIS.RouteZoneControl
Wholesale_CODIS.EXPFRTRULE
Wholesale_CODIS.OPEXCPTJRN
Wholesale_CODIS.TRPTYPCD
Wholesale_CODIS.RTDDLV
Wholesale_CODIS.YABFREP
Wholesale_CODIS.POPlannedComparison
Wholesale_CODIS.OrderArrivalCode
Wholesale_CODIS.ApproversList
Wholesale_CODIS.AWHSMAS
Wholesale_CODIS.DSCADJOO
Wholesale_CODIS.TOUntrippedComparison
Wholesale_CODIS.ORDREV
Wholesale_CODIS.BTTRIPD
Wholesale_CODIS.AAORDTYP
Wholesale_CODIS.OrderArrivalGroup
Wholesale_CODIS.RIMSRESD
Wholesale_CODIS.MOPlannedComparison
Wholesale_CODIS.DashboardValuelist
Wholesale_CODIS.BTTRIPH
Wholesale_CODIS.CODATAH
Wholesale_CODIS.EXTORIT_old
Wholesale_CODIS.ItemComparison
Wholesale_CODIS.YAARREP
Wholesale_CODIS.OpenOrderConsumerAddress
Wholesale_CODIS.OHIComparison
Wholesale_CODIS.YAAFREP
Wholesale_CODIS.OrderCancellationReasonCode
Wholesale_CODIS.BTRSNCDE
Wholesale_CODIS.RIMSJOBD
Wholesale_CODIS.EXPFRTRULA
Wholesale_CODIS.CODATAK
Wholesale_CODIS.MOFirmComparison
Wholesale_CODIS.RIMSJOB
Wholesale_CODIS.LOCMST
Wholesale_CODIS.ACNLITM
Wholesale_CODIS.DW010EW1
Wholesale_CODIS.TOTrippedComparison
Wholesale_CODIS.MC2CUEPF
Wholesale_CODIS.CODATAN
Wholesale_CODIS.ACRDMAS
Wholesale_CODIS.COMAST
Wholesale_CODIS.FRTEXCA
Wholesale_CODIS.BTITSCN
Wholesale_CODIS.CODATAN_XBK
Wholesale_CODIS.extorit_old2
Wholesale_CODIS.EXTORIT_test
Wholesale_CODIS.RequestDateChangeCodes
Wholesale_CODIS.EXTORD
Wholesale_CODIS.DWBOLRC
Wholesale_CODIS.COComparison
Wholesale_CODIS_Wrk.DSCADJOO
Wholesale_CODIS_Wrk.BTITSCN
Wholesale_CODIS_Wrk.EXTORIT
Wholesale_CODIS_Wrk.ACNLITM
Wholesale_CODIS_Wrk.YABFREP
Wholesale_CODIS_Wrk.LOCMST
Wholesale_CODIS_Wrk.CODATAN_reload
Wholesale_CODIS_Wrk.BTTRIPD
Wholesale_CODIS_Wrk.ACNLORD
Wholesale_CODIS_Wrk.DW010EW1
Wholesale_CODIS_Wrk.YAARREP
Wholesale_CODIS_Wrk.EXTORITTemp
Wholesale_CODIS_Wrk.CODATAN
Wholesale_CODIS_Wrk.OPEXCPTJRN
Wholesale_CODIS_WVF.COMAST
Wholesale_CODIS_WVF.MC2CUEPF
Wholesale_CODIS_WVF.BTITSCN
Wholesale_CODIS_WVF.OrderCancellationReasonCode
Wholesale_CODIS_WVF.CODATAN
Wholesale_CODIS_WVF.CODATAK
Wholesale_CODIS_WVF.AshleyWarehouseMaster
Wholesale_CODIS_WVF.STDTRM
Wholesale_CODIS_WVF.AAORDTYP
Wholesale_CODIS_WVF.EXTORIT
Wholesale_CODIS_WVF.TRPTYPCD
Wholesale_CODIS_WVF.EXTORD
Wholesale_CODIS_WVF.ACRDMAS
Wholesale_CODIS_MIL.BTITSCN
Wholesale_CODIS_WNK.BTITSCN
Wholesale_CODIS_xbk.EXTORIT_full
Wholesale_CODIS_AFI.DESDFTF
Wholesale_CODIS_AFI.TransferOrderDetails_TrippedFrom
Wholesale_CODIS_AFI.TransferOrderDetails_UnTrippedTO
Wholesale_CODIS_AFI.MoFirm
Wholesale_CODIS_AFI.TransferOrderDetails_TrippedTO
Wholesale_CODIS_AFI.RIMSRESE
Wholesale_CODIS_AFI.TransferOrderDetails_UnTrippedFrom
Wholesale_CODIS_AFI.SCHCTL
Wholesale_CODIS_AFI.ESCHJTRK
Wholesale_CODIS_AFI.MoPlanned
Wholesale_CODIS_AFI.ORDSCHD
Wholesale_CODIS_AFI_Wrk.ESCHJTRK
*/