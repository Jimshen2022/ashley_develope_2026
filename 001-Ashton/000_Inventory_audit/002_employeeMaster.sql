    SELECT
        t.Plant,
        cast(t.EmployeeNumber as int) as EmployeeNumber,
        t.EmpReportName,
        t.GroupNumber,
        t.Schedule,
        t.HomeDepartment,
        t.TerminationDate
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR as t


    SELECT
        t.Plant,
        cast(t.EmployeeNumber as int) as EmployeeNumber,
        t.EmpReportName,
        t.GroupNumber,
        t.Schedule,
        t.HomeDepartment,
        t.TerminationDate,
        ROW_NUMBER() OVER (PARTITION BY t.HomeDepartment Order by t.EmployeeNumber) as Depart_No
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR as t
    order by t.HomeDepartment,t.EmployeeNumber


