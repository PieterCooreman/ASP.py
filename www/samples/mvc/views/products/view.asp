<%
' Product detail view
Dim product
Set product = ViewData

If product Is Nothing Then
%>
    <div class="alert alert-danger">
        <i class="bi bi-exclamation-triangle me-2"></i>
        Product not found.
    </div>
<%
Else
%>

<nav aria-label="breadcrumb">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="?controller=product&action=list">Products</a></li>
        <li class="breadcrumb-item active"><%=HtmlEncode(product.Name)%></li>
    </ol>
</nav>

<div class="row g-4">
    <div class="col-lg-8">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Product Details</h5>
            </div>
            <div class="card-body">
                <div class="mb-4">
                    <h2 class="display-6"><%=HtmlEncode(product.Name)%></h2>
                </div>

                <div class="row mb-4">
                    <div class="col-md-6">
                        <h6 class="text-muted">Price</h6>
                        <p class="display-5 text-success fw-bold">$<%=FormatNumber(product.Price, 2)%></p>
                    </div>
                    <div class="col-md-6">
                        <h6 class="text-muted">Stock Level</h6>
                        <p class="display-5">
                            <%If product.Quantity = 0 Then%>
                                <span class="badge bg-danger p-2">Out of Stock</span>
                            <%ElseIf product.Quantity < 10 Then%>
                                <span class="badge bg-warning p-2">Low Stock (<%=product.Quantity%>)</span>
                            <%Else%>
                                <span class="badge bg-success p-2"><%=product.Quantity%> Available</span>
                            <%End If%>
                        </p>
                    </div>
                </div>

                <hr>

                <div class="mb-4">
                    <h6 class="text-muted mb-2">Description</h6>
                    <p><%=HtmlEncode(product.Description)%></p>
                </div>

                <hr>

                <div class="row text-muted">
                    <div class="col-md-6">
                        <small>
                            <strong>Product ID:</strong><br>
                            <code><%=product.ID%></code>
                        </small>
                    </div>
                    <div class="col-md-6">
                        <small>
                            <strong>Created:</strong><br>
                            <%=FormatDateTime(product.CreatedAt, vbGeneralDate)%>
                        </small>
                    </div>
                </div>
            </div>
            <div class="card-footer bg-light">
                <a href="?controller=product&action=edit&id=<%=product.ID%>" class="btn btn-warning">
                    <i class="bi bi-pencil me-1"></i>Edit Product
                </a>
                <a href="?controller=product&action=delete&id=<%=product.ID%>" class="btn btn-danger">
                    <i class="bi bi-trash me-1"></i>Delete Product
                </a>
                <a href="?controller=product&action=list" class="btn btn-secondary">
                    <i class="bi bi-arrow-left me-1"></i>Back to List
                </a>
            </div>
        </div>
    </div>

    <div class="col-lg-4">
        <div class="card bg-light shadow-sm">
            <div class="card-body">
                <h6 class="card-title mb-3">Quick Actions</h6>
                <a href="?controller=product&action=create" class="btn btn-sm btn-primary d-block mb-2">
                    <i class="bi bi-plus-circle me-1"></i>Add Another Product
                </a>
                <a href="?controller=product&action=list" class="btn btn-sm btn-outline-secondary d-block">
                    <i class="bi bi-list me-1"></i>View All Products
                </a>
            </div>
        </div>

        <div class="card shadow-sm mt-3">
            <div class="card-body small text-muted">
                <p class="mb-0">
                    <i class="bi bi-info-circle me-1"></i>
                    Manage this product or return to the catalog.
                </p>
            </div>
        </div>
    </div>
</div>

<%
End If
%>
