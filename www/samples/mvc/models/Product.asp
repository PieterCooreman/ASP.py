<%
'================================================================================
' Product.asp - Product data model and database operations
'================================================================================

Class Product
    Public ID
    Public Name
    Public Description
    Public Price
    Public Quantity
    Public CreatedAt
    
    Public Sub Init(id, name, desc, price, qty)
        Me.ID = id
        Me.Name = name
        Me.Description = desc
        Me.Price = CDbl(price)
        Me.Quantity = CInt(qty)
        Me.CreatedAt = Now()
    End Sub
End Class

Class ProductModel
  
    Private conn          
    
    ' Get all products
    Public Function GetAll()
        Dim conn, rs, products(), i
        Set conn = Server.CreateObject("ADODB.Connection")
        Set products = Nothing
        
        On Error Resume Next
        conn.Open "Provider=SQLite;Data Source=" & dbPath
        
        If Err.Number <> 0 Then Exit Function
        
        Set rs = conn.Execute("SELECT * FROM products ORDER BY id DESC")
        
        If rs.EOF Then
            ' No products
            Set conn = Nothing
            Set rs = Nothing
            Exit Function
        End If
        
        ' Count records
        rs.MoveLast()
        Dim count
        count = rs.RecordCount
        
        If count = 0 Then
            Set conn = Nothing
            Set rs = Nothing
            Exit Function
        End If
        
        ReDim products(count - 1)
        rs.MoveFirst()
        
        For i = 0 To count - 1
            Set products(i) = New Product
            products(i).ID = rs.Fields("id").Value
            products(i).Name = rs.Fields("name").Value
            products(i).Description = rs.Fields("description").Value
            products(i).Price = rs.Fields("price").Value
            products(i).Quantity = rs.Fields("quantity").Value
            products(i).CreatedAt = rs.Fields("created_at").Value
            rs.MoveNext()
        Next
        
        rs.Close()
        conn.Close()
        Set rs = Nothing
        Set conn = Nothing
        
        On Error Goto 0
        
        GetAll = products
    End Function
    
    ' Get product by ID
    Public Function GetByID(id)
        Dim conn, rs, product
        Set conn = Server.CreateObject("ADODB.Connection")
        Set product = Nothing
        
        On Error Resume Next
        conn.Open "Provider=SQLite;Data Source=" & dbPath
        
        If Err.Number <> 0 Then Exit Function
        
        Dim sql
        sql = "SELECT * FROM products WHERE id = " & CInt(id)
        Set rs = conn.Execute(sql)
        
        If Not rs.EOF Then
            Set product = New Product
            product.ID = rs.Fields("id").Value
            product.Name = rs.Fields("name").Value
            product.Description = rs.Fields("description").Value
            product.Price = rs.Fields("price").Value
            product.Quantity = rs.Fields("quantity").Value
            product.CreatedAt = rs.Fields("created_at").Value
        End If
        
        rs.Close()
        conn.Close()
        Set rs = Nothing
        Set conn = Nothing
        
        On Error Goto 0
        
        Set GetByID = product
    End Function
    
    ' Add a new product
    Public Function Add(name, description, price, quantity)
        Dim conn, sql
        Set conn = Server.CreateObject("ADODB.Connection")
        
        On Error Resume Next
        conn.Open "Provider=SQLite;Data Source=" & dbPath
        
        If Err.Number <> 0 Then
            Add = 0
            Exit Function
        End If
        
        sql = "INSERT INTO products (name, description, price, quantity) VALUES (" & _
              "'" & Replace(name, "'", "''") & "', " & _
              "'" & Replace(description, "'", "''") & "', " & _
              CDbl(price) & ", " & _
              CInt(quantity) & ")"
        
        conn.Execute(sql)
        
        ' Get last inserted ID
        Set rs = conn.Execute("SELECT last_insert_rowid() AS last_id")
        Dim lastID
        lastID = rs.Fields(0).Value
        Add = lastID
        
        rs.Close()
        conn.Close()
        Set rs = Nothing
        Set conn = Nothing
        
        On Error Goto 0
    End Function
    
    ' Update a product
    Public Function Update(id, name, description, price, quantity)
        Dim conn, sql
        Set conn = Server.CreateObject("ADODB.Connection")
        
        On Error Resume Next
        conn.Open "Provider=SQLite;Data Source=" & dbPath
        
        If Err.Number <> 0 Then Exit Function
        
        sql = "UPDATE products SET " & _
              "name='" & Replace(name, "'", "''") & "', " & _
              "description='" & Replace(description, "'", "''") & "', " & _
              "price=" & CDbl(price) & ", " & _
              "quantity=" & CInt(quantity) & " " & _
              "WHERE id=" & CInt(id)
        
        conn.Execute(sql)
        
        conn.Close()
        Set conn = Nothing
        
        On Error Goto 0
    End Function
    
    ' Delete a product
    Public Function Delete(id)
        Dim conn, sql
        Set conn = Server.CreateObject("ADODB.Connection")
        
        On Error Resume Next
        conn.Open "Provider=SQLite;Data Source=" & dbPath
        
        If Err.Number <> 0 Then Exit Function
        
        sql = "DELETE FROM products WHERE id=" & CInt(id)
        conn.Execute(sql)
        
        conn.Close()
        Set conn = Nothing
        
        On Error Goto 0
    End Function
End Class

%>
