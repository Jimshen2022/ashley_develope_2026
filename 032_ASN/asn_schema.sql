select top 10 * from t_tran_log where  lot_number ='666158431209'
select * from t_tran_log where  lot_number ='666158339878'

select top 10 * from t_asn
select top 10 * from t_asn_detail
select * from t_asn_detail where customer_po_number = 'P2TRQ93'
select top 10 * from t_trailer


select *
from t_tran_log
where control_number_2 = 'P2TSH68' and tran_type in ('151','951')


select control_number, control_number_2, item_number, sum(case when tran_type = '951' then -tran_qty else tran_qty end) as tran_qty
from t_tran_log
where control_number_2 = 'P2TSH68' and tran_type in ('151','951')
group by control_number, control_number_2, item_number


SELECT *
FROM t_asn_detail
WHERE '688806131450' BETWEEN serial_number_start AND serial_number_end;