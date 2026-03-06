<%
' Product create/edit form view
Dim product, isEdit, pageTitle, submitAction
Set product = ViewData

isEdit = (Not product Is Nothing)

If isEdit Then
    pageTitle = "Edit Product"
    submitAction = "update"
Else
    pageTitle = "Create New Product"
    submitAction = "save"
End If
%>

<nav aria-label="breadcrumb">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="?controller=product&action=list">Products</a></li>
        <li class="breadcrumb-item active"><%=pageTitle%></li>
    </ol>
</nav>

<div class="row">
    <div class="col-lg-8 offset-lg-2">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0"><%=pageTitle%></h5>
            </div>
            <div class="card-body">
                <form method="POST" action="?controller=product&action=<%=submitAction%>" class="needs-validation" novalidate>
                    
                    <%If isEdit Then%>
                    <input type="hidden" name="id" value="<%=product.ID%>">
                    <%End If%>

                    <div class="mb-3">
                        <label for="name" class="form-label">Product Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" placeholder="Enter product name" 
                               value="<%If isEdit Then %><%=HtmlEncode(product.Name)%><%End If%>" 
                               required>
                        <div class="invalid-feedback">
                            Product name is required.
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="4" placeholder="Enter product description"><%If isEdit Then %><%=HtmlEncode(product.Description)%><%End If%></textarea>
                        <small class="form-text text-muted">Optional: Provide details about the product</small>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="price" class="form-label">Price <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text">$</span>
                                    <input type="number" class="form-control" id="price" name="price" 
                                           placeholder="0.00" step="0.01" min="0"
                                           value="<%If isEdit Then %><%=FormatNumber(product.Price, 2)%><%End If%>"
                                           required>
                                </div>
                                <div class="invalid-feedback">
                                    Price is required and must be a valid number.
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="quantity" class="form-label">Quantity in Stock</label>
                                <input type="number" class="form-control" id="quantity" name="quantity" 
                                       placeholder="0" min="0"
                                       value="<%If isEdit Then %><%=product.Quantity%><%Else%>0<%End If%>">
                                <small class="form-text text-muted">Optional: Leave blank for 0</small>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                        <a href="?controller=product&action=list" class="btn btn-secondary">
                            <i class="bi bi-x-circle me-1"></i>Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-circle me-1"></i><%If isEdit Then%>Update Product<%Else%>Create Product<%End If%>
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div class="alert alert-info mt-4">
            <i class="bi bi-lightbulb me-2"></i>
            <strong>Tip:</strong> All fields with <span class="text-danger">*</span> are required.
        </div>
    </div>
</div>

<script>
    // Bootstrap form validation
    (function() {
        'use strict';
        window.addEventListener('load', function() {
            var forms = document.querySelectorAll('.needs-validation');
            Array.prototype.slice.call(forms).forEach(function(form) {
                form.addEventListener('submit', function(event) {
                    if (!form.checkValidity()) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        }, false);
    })();
</script>
