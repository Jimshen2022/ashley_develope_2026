Attribute VB_Name = "b05_product"
Sub b05_product_()
    Application.ScreenUpdating = False
    Dim i&, arr, nrow&
    
    With Sheet1
        .Range("AQ1").Value = "Product_category"
        arr = .Range("A1").CurrentRegion
        nrow = UBound(arr, 1)
        
        For i = 2 To nrow
            arr(i, 43) = arr(i, 25)   ' AI (Category) -> AQ (Product_category)
        Next i
        
        .Range("AQ1").Resize(nrow, 1).Value = Application.Index(arr, , 43)
    End With
    
    Application.ScreenUpdating = True
    Erase arr
    
End Sub
