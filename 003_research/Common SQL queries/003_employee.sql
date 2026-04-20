WITH grp as (
    select *
    from Distribution_Warehouse_Wholesale.[Group] as t1
    where t1.wh_id IN ('51')),
dept as (
    select *
    from Distribution_Warehouse_Wholesale.Department as t1
    where t1.wh_id IN ('51')
	)
select EMEMPL,
EMCOMP,
EMFACL,
EMRNAM,
EMSCHD,
EMPLNT,
EMPGRPE,
EMJTL,
EMDEPT,
EMSUPR,
EMMDPT,
EMWC,
EMPBDGE,
ESHFTCN,
EBEGDTE,
EMEFFDT
from Distribution_Warehouse_Wholesale.t_employee e
LEFT JOIN dept as d1 on e.wh_id = d1.wh_id and e.dept = d1.department_code
LEFT JOIN grp as g on e.wh_id =g.wh_id and e.group_nbr = g.GroupNbr
where e.wh_id = '51'
