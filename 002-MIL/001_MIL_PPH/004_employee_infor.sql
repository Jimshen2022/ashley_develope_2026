WITH emp AS (
    SELECT *
    FROM Manufacturing_ProductionPlanning_MIL.EMPMST
)
    SELECT 
        RIGHT('00000' + RTRIM(CAST(t.EmployeeNumber AS VARCHAR(10))), 5) AS employee_id,
        t.Company,
        t.Facility,
        t.EmpReportName,
        t.Schedule,
        t.Plant,
        t.GroupNumber,
        t.JobTitle,
        t.HomeDepartment,
        t.Supervisor,
        t.MfgDepartment,
        t.MfgWorkCenter,
        t.BadgeNumber AS as400_badge_user_id,
        t.ShiftNumber,
        t.BeginningDate,
        t.EffectivityDate,
        t.TerminationDate,
        t.DateRecordAdded,
        e.FirstName,
        e.LastName,
        e.BadgeNbr AS as400_badge_number,
        e.UserP   AS as400_badge_user_name
    FROM Manufacturing_ProductionPlanning_MIL.EMMSTR AS t
    LEFT JOIN emp AS e
        ON e.BadgeNbr = t.BadgeNumber
    WHERE (t.TerminationDate IS NULL OR t.TerminationDate < '1920-01-01')