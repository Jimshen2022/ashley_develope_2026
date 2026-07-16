Attribute VB_Name = "a00_Public_variances"
Public startdate As Date
Public enddate As Date
Public Sub InitDates()
    startdate = Sheet25.Range("C2").Value
    enddate = Sheet25.Range("C3").Value
End Sub

