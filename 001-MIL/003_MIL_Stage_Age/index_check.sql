SELECT 
    t.name AS TableName,
    t.distribution_policy,
    i.index_type_desc
FROM sys.tables t
LEFT JOIN sys.indexes i 
       ON t.object_id = i.object_id 
      AND i.index_id = 1
WHERE t.name IN ('ACTAUDT','WVCNTSDA','WVCNTSD','WVCNTHD','WVCNTHDA');


SELECT 
    t.name AS TableName,
    t.distribution_policy,
    i.index_type_desc
FROM sys.tables t
LEFT JOIN sys.indexes i 
       ON t.object_id = i.object_id 
      AND i.index_id = 1
WHERE t.name IN ('ACTAUDT','WVCNTSDA','WVCNTSD','WVCNTHD','WVCNTHDA');
