<%
' Product delete confirmation view
Dim id, model, product
Set model = New ProductModel

id = ViewData
Set product = model.GetByID(id)
%>

<nav aria-label="breadcrumb">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="?controller=product&action=list">Products</a></li>
        <li class="breadcrumb-item"><a href="?controller=product&action=view&id=<%=id%>">View</a></li>
        <li class="breadcrumb-item active">Delete</li>
    </ol>
</nav>

<%
If product Is Nothing Then
%>
    <div class="alert alert-danger">
        <i class="bi bi-exclamation-triangle me-2"></i>
        Product not found.
    </div>
    <a href="?controller=product&action=list" class="btn btn-secondary">Back to Products</a>
<%
Else
%>
    <div class="row">
        <div class="col-lg-6 offset-lg-3">
            <div class="card border-danger shadow-sm">
                <div class="card-header bg-danger text-white">
                    <h5 class="mb-0">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        Confirm Delete
                    </h5>
                </div>
                <div class="card-body">
                    <p>
                        You are about to permanently delete the following product:
                    </p>
                    <div class="alert alert-warning">
                        <strong><%=HtmlEncode(product.Name)%></strong><br>
                        <small class="text-muted">ID: <%=product.ID%></small>
                    </div>
                    <p class="text-muted">
                        <i class="bi bi-info-circle me-1"></i>
                        This action cannot be undone.
                    </p>
                </div>
                <div class="card-footer bg-light">
                    <form method="POST" action="?controller=product&action=remove" class="d-grid gap-2 d-md-flex justify-content-md-end">
                        <input type="hidden" name="id" value="<%=id%>">
                        
                        <a href="?controller=product&action=view&id=<%=id%>" class="btn btn-secondary">
                            <i class="bi bi-x-circle me-1"></i>Cancel
                        </a>
                        <button type="submit" class="btn btn-danger">
                            <i class="bi bi-trash me-1"></i>Yes, Delete Product
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
<%
End If
%>
