<%
' Products list view
Dim products, i, product
products = ViewData
%>

<div class="row mb-4">
    <div class="col">
        <h1 class="display-6">Product Catalog</h1>
        <p class="text-muted">Browse and manage all products in your inventory</p>
    </div>
    <div class="col-auto">
        <a href="?controller=product&action=create" class="btn btn-primary btn-lg">
            <i class="bi bi-plus-circle me-2"></i>Add New Product
        </a>
    </div>
</div>

<%
If IsNull(products) Or IsEmpty(products) Then
%>
    <div class="alert alert-info">
        <i class="bi bi-info-circle me-2"></i>
        No products found. <a href="?controller=product&action=create" class="alert-link">Create one now</a>!
    </div>
<%
Else
%>
    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Product Name</th>
                    <th>Description</th>
                    <th class="text-end">Price</th>
                    <th class="text-center">Quantity</th>
                    <th class="text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
<%
    For i = LBound(products) To UBound(products)
        Set product = products(i)
        If Not product Is Nothing Then
%>
                <tr>
                    <td>
                        <code><%=product.ID%></code>
                    </td>
                    <td>
                        <strong><%=HtmlEncode(product.Name)%></strong>
                    </td>
                    <td>
                        <small class="text-muted"><%=HtmlEncode(Left(product.Description, 50))%><%If Len(product.Description) > 50 Then %>...<%End If%></small>
                    </td>
                    <td class="text-end">
                        <span class="badge bg-success">$<%=FormatNumber(product.Price, 2)%></span>
                    </td>
                    <td class="text-center">
                        <%If product.Quantity = 0 Then%>
                            <span class="badge bg-danger">Out of Stock</span>
                        <%Else%>
                            <span class="badge bg-info"><%=product.Quantity%></span>
                        <%End If%>
                    </td>
                    <td class="text-center">
                        <a href="?controller=product&action=view&id=<%=product.ID%>" class="btn btn-sm btn-info" title="View">
                            <i class="bi bi-eye"></i>
                        </a>
                        <a href="?controller=product&action=edit&id=<%=product.ID%>" class="btn btn-sm btn-warning" title="Edit">
                            <i class="bi bi-pencil"></i>
                        </a>
                        <a href="?controller=product&action=delete&id=<%=product.ID%>" class="btn btn-sm btn-danger" title="Delete">
                            <i class="bi bi-trash"></i>
                        </a>
                    </td>
                </tr>
<%
        End If
    Next
%>
            </tbody>
        </table>
    </div>

    <div class="alert alert-secondary">
        <i class="bi bi-info-circle me-2"></i>
        Showing <strong><%=UBound(products) - LBound(products) + 1%></strong> product(s)
    </div>
<%
End If
%>
