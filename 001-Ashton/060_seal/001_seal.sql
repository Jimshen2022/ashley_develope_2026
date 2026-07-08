-- t_seal

select seal_number,* from t_load_master (nolock) where load_id like '0065805%'

select carton_label,* from t_order (nolock) where order_number like '0065805%'

select hu_id_2,* from t_tran_log (nolock) where tran_type='345' and control_number_2 like '0065805%'