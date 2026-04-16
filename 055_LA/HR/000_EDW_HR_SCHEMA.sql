#,TABLE_SCHEMA,TABLE_NAME
1,MasterData_HR,TurnoverProjectData
2,MasterData_HR,TurnoverProjectData_Load
3,HR_Enh,Emp_LevelLeaders_Hierarchy
4,HR_Enh,ADS_Xbk
5,HR_Enh,EmployeeHistory_LOAD
6,HR_Enh,EmployeeHistory
7,PowerBI_HR,EmployeeSummary
8,PowerBI_HR,HeadCount
9,PowerBI_HR,RetailRSACapacity_ToTable
10,PowerBI_HR,Emp_LevelLeaders_Hierarchy
11,PowerBI_HR,AllAbsenteeHours
12,PowerBI_HR,Separations
13,PowerBI_HR,EmployeeHistory
14,HR_DW,FactEmployeeHistory
138,MasterData_HR,CUREMM6
select top 1000 * from MasterData_ProductKnowledge.ItemSeries
select top 1000 * from HR_DW.FactEmployeeHistory
select top 1000 * from PowerBI_HR.EmployeeHistory
select top 1000 * from HR_Enh.EmployeeHistory
select top 1000 * from MasterData_HR.TurnoverProjectData
select top 1000 * from MasterData_HR.CUREMM6
select top 1000 * from MasterData_HR.CUREMM6

select top 10 * from Wholesale_ProductSourcing_AFI.Bookings
