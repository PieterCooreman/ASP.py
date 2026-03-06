<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #include file="utils.asp" -->
<!-- #include file="../models/Product.asp" -->
<%
'================================================================================
' product.asp - Product Controller
' Handles all product-related requests
'================================================================================

Dim pageAction, dbModel, itemList, itemObj, itemId
Dim itemName, itemDesc, itemPrice, itemQty

' Get action from request
pageAction = Request.QueryString("action")
If pageAction = "" Then pageAction = "list"

' Increment page view counter
IncrementPageViews()

' Create product model instance
On Error Resume Next
Set dbModel = New ProductModel
If Err.Number <> 0 Then
    Response.Write "Error creating model: " & Err.Description
    Response.End()
End If
On Error Goto 0

' Route to appropriate action
Select Case LCase(pageAction)
    Case "list"
        Call ActionList()
    Case "view"
        Call ActionView()
    Case "create"
        Call ActionCreate()
    Case "edit"
        Call ActionEdit()
    Case "delete"
        Call ActionDelete()
    Case "save"
        Call ActionSave()
    Case "update"
        Call ActionUpdate()
    Case "remove"
        Call ActionRemove()
    Case Else
        Call ActionList()
End Select

Set dbModel = Nothing

'================================================================================
' ACTION: List all products
'================================================================================
Sub ActionList()
    Dim i
    
    Response.Write "<!DOCTYPE html>" & vbCrLf
    Response.Write "<html lang='en'>" & vbCrLf
    Response.Write "<head>" & vbCrLf
    Response.Write "    <meta charset='utf-8'>" & vbCrLf
    Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
    Response.Write "    <title>Products - ASPpy MVC</title>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; }</style>" & vbCrLf
    Response.Write "</head>" & vbCrLf
    Response.Write "<body>" & vbCrLf
    
    ' Navigation
    Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <a class='navbar-brand' href='index.asp'><i class='bi bi-gear-fill me-2'></i>ASPpy MVC</a>" & vbCrLf
    Response.Write "            <button class='navbar-toggler' type='button' data-bs-toggle='collapse' data-bs-target='#mainNav'><span class='navbar-toggler-icon'></span></button>" & vbCrLf
    Response.Write "            <div class='collapse navbar-collapse' id='mainNav'>" & vbCrLf
    Response.Write "                <ul class='navbar-nav ms-auto'>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='index.asp'><i class='bi bi-house me-1'></i>Home</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=product&action=list'><i class='bi bi-box me-1'></i>Products</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=home&action=about'><i class='bi bi-info-circle me-1'></i>About</a></li>" & vbCrLf
    Response.Write "                </ul>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </nav>" & vbCrLf
    
    Response.Write "    <main class='py-4'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <div class='row mb-4'>" & vbCrLf
    Response.Write "                <div class='col'>" & vbCrLf
    Response.Write "                    <h1 class='display-6'>Product Catalog</h1>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "                <div class='col-auto'>" & vbCrLf
    Response.Write "                    <a href='?controller=product&action=create' class='btn btn-primary btn-lg'><i class='bi bi-plus-circle me-2'></i>Add Product</a>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    
    itemList = dbModel.GetAll()
    
    If IsNull(itemList) Or IsEmpty(itemList) Then
        Response.Write "            <div class='alert alert-info'>" & vbCrLf
        Response.Write "                <i class='bi bi-info-circle me-2'></i>No products found. <a href='?controller=product&action=create' class='alert-link'>Create one</a>!" & vbCrLf
        Response.Write "            </div>" & vbCrLf
    Else
        Response.Write "            <table class='table table-hover'>" & vbCrLf
        Response.Write "                <thead class='table-dark'>" & vbCrLf
        Response.Write "                    <tr><th>ID</th><th>Name</th><th>Price</th><th>Qty</th><th>Actions</th></tr>" & vbCrLf
        Response.Write "                </thead>" & vbCrLf
        Response.Write "                <tbody>" & vbCrLf
        
        For i = LBound(itemList) To UBound(itemList)
            Set itemObj = itemList(i)
            If Not itemObj Is Nothing Then
                Response.Write "                    <tr>" & vbCrLf
                Response.Write "                        <td>" & itemObj.ID & "</td>" & vbCrLf
                Response.Write "                        <td>" & HtmlEncode(itemObj.Name) & "</td>" & vbCrLf
                Response.Write "                        <td>$" & FormatNumber(itemObj.Price, 2) & "</td>" & vbCrLf
                Response.Write "                        <td>" & itemObj.Quantity & "</td>" & vbCrLf
                Response.Write "                        <td>" & vbCrLf
                Response.Write "                            <a href='?controller=product&action=view&id=" & itemObj.ID & "' class='btn btn-sm btn-info'><i class='bi bi-eye'></i></a> " & vbCrLf
                Response.Write "                            <a href='?controller=product&action=edit&id=" & itemObj.ID & "' class='btn btn-sm btn-warning'><i class='bi bi-pencil'></i></a> " & vbCrLf
                Response.Write "                            <a href='?controller=product&action=delete&id=" & itemObj.ID & "' class='btn btn-sm btn-danger'><i class='bi bi-trash'></i></a>" & vbCrLf
                Response.Write "                        </td>" & vbCrLf
                Response.Write "                    </tr>" & vbCrLf
            End If
        Next
        
        Response.Write "                </tbody>" & vbCrLf
        Response.Write "            </table>" & vbCrLf
    End If
    
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </main>" & vbCrLf
    
    ' Footer
    Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
    Response.Write "        <div class='container text-center'>" & vbCrLf
    Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample</p>" & vbCrLf
    Response.Write "            <small>Built with ASPpy</small>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </footer>" & vbCrLf
    Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
    Response.Write "</body>" & vbCrLf
    Response.Write "</html>" & vbCrLf
End Sub

Sub ActionView()
    itemId = Request.QueryString("id")
    
    If itemId = "" Then
        Response.Redirect "?controller=product&action=list"
        Exit Sub
    End If
    
    Set itemObj = dbModel.GetByID(itemId)
    
    If itemObj Is Nothing Then
        Response.Write "<!DOCTYPE html>" & vbCrLf
        Response.Write "<html lang='en'>" & vbCrLf
        Response.Write "<head>" & vbCrLf
        Response.Write "    <meta charset='utf-8'>" & vbCrLf
        Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
        Response.Write "    <title>Product Not Found - ASPpy MVC</title>" & vbCrLf
        Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
        Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
        Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; }</style>" & vbCrLf
        Response.Write "</head>" & vbCrLf
        Response.Write "<body>" & vbCrLf
        Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
        Response.Write "        <div class='container'>" & vbCrLf
        Response.Write "            <a class='navbar-brand' href='index.asp'><i class='bi bi-gear-fill me-2'></i>ASPpy MVC</a>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </nav>" & vbCrLf
        Response.Write "    <main class='py-4'>" & vbCrLf
        Response.Write "        <div class='container'>" & vbCrLf
        Response.Write "            <div class='alert alert-danger'><i class='bi bi-exclamation-triangle me-2'></i>Product not found.</div>" & vbCrLf
        Response.Write "            <a href='?controller=product&action=list' class='btn btn-primary'><i class='bi bi-arrow-left me-1'></i>Back to Products</a>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </main>" & vbCrLf
        Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
        Response.Write "        <div class='container text-center'>" & vbCrLf
        Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample</p>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </footer>" & vbCrLf
        Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
        Response.Write "</body>" & vbCrLf
        Response.Write "</html>" & vbCrLf
        Exit Sub
    End If
    
    Response.Write "<!DOCTYPE html>" & vbCrLf
    Response.Write "<html lang='en'>" & vbCrLf
    Response.Write "<head>" & vbCrLf
    Response.Write "    <meta charset='utf-8'>" & vbCrLf
    Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
    Response.Write "    <title>" & HtmlEncode(itemObj.Name) & " - ASPpy MVC</title>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; }</style>" & vbCrLf
    Response.Write "</head>" & vbCrLf
    Response.Write "<body>" & vbCrLf
    Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <a class='navbar-brand' href='index.asp'><i class='bi bi-gear-fill me-2'></i>ASPpy MVC</a>" & vbCrLf
    Response.Write "            <button class='navbar-toggler' type='button' data-bs-toggle='collapse' data-bs-target='#mainNav'><span class='navbar-toggler-icon'></span></button>" & vbCrLf
    Response.Write "            <div class='collapse navbar-collapse' id='mainNav'>" & vbCrLf
    Response.Write "                <ul class='navbar-nav ms-auto'>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='index.asp'><i class='bi bi-house me-1'></i>Home</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=product&action=list'><i class='bi bi-box me-1'></i>Products</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=home&action=about'><i class='bi bi-info-circle me-1'></i>About</a></li>" & vbCrLf
    Response.Write "                </ul>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </nav>" & vbCrLf
    Response.Write "    <main class='py-4'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <div class='row mb-4'>" & vbCrLf
    Response.Write "                <div class='col-md-8'>" & vbCrLf
    Response.Write "                    <div class='card shadow-sm'>" & vbCrLf
    Response.Write "                        <div class='card-body'>" & vbCrLf
    Response.Write "                            <h1 class='card-title display-5'>" & HtmlEncode(itemObj.Name) & "</h1>" & vbCrLf
    Response.Write "                            <hr>" & vbCrLf
    Response.Write "                            <div class='row mb-4'>" & vbCrLf
    Response.Write "                                <div class='col-md-6'>" & vbCrLf
    Response.Write "                                    <p class='text-muted'>Price</p>" & vbCrLf
    Response.Write "                                    <h3 class='text-success'>$" & CStr(CDbl(itemObj.Price)) & "</h3>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                                <div class='col-md-6'>" & vbCrLf
    Response.Write "                                    <p class='text-muted'>In Stock</p>" & vbCrLf
    Response.Write "                                    <h3 class='text-primary'>" & itemObj.Quantity & " units</h3>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                            </div>" & vbCrLf
    Response.Write "                            <div class='mb-4'>" & vbCrLf
    Response.Write "                                <p class='text-muted'>Description</p>" & vbCrLf
    Response.Write "                                <p>" & HtmlEncode(itemObj.Description) & "</p>" & vbCrLf
    Response.Write "                            </div>" & vbCrLf
    Response.Write "                            <div class='btn-group' role='group'>" & vbCrLf
    Response.Write "                                <a href='?controller=product&action=edit&id=" & itemObj.ID & "' class='btn btn-warning'><i class='bi bi-pencil me-1'></i>Edit</a>" & vbCrLf
    Response.Write "                                <a href='?controller=product&action=delete&id=" & itemObj.ID & "' class='btn btn-danger'><i class='bi bi-trash me-1'></i>Delete</a>" & vbCrLf
    Response.Write "                                <a href='?controller=product&action=list' class='btn btn-secondary'><i class='bi bi-arrow-left me-1'></i>Back to List</a>" & vbCrLf
    Response.Write "                            </div>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                    </div>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </main>" & vbCrLf
    Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
    Response.Write "        <div class='container text-center'>" & vbCrLf
    Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample</p>" & vbCrLf
    Response.Write "            <small>Built with ASPpy</small>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </footer>" & vbCrLf
    Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
    Response.Write "</body>" & vbCrLf
    Response.Write "</html>" & vbCrLf
End Sub

Sub ActionCreate()
    Response.Write "<!DOCTYPE html>" & vbCrLf
    Response.Write "<html lang='en'>" & vbCrLf
    Response.Write "<head>" & vbCrLf
    Response.Write "    <meta charset='utf-8'>" & vbCrLf
    Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
    Response.Write "    <title>Create Product - ASPpy MVC</title>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; }</style>" & vbCrLf
    Response.Write "</head>" & vbCrLf
    Response.Write "<body>" & vbCrLf
    Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <a class='navbar-brand' href='index.asp'><i class='bi bi-gear-fill me-2'></i>ASPpy MVC</a>" & vbCrLf
    Response.Write "            <button class='navbar-toggler' type='button' data-bs-toggle='collapse' data-bs-target='#mainNav'><span class='navbar-toggler-icon'></span></button>" & vbCrLf
    Response.Write "            <div class='collapse navbar-collapse' id='mainNav'>" & vbCrLf
    Response.Write "                <ul class='navbar-nav ms-auto'>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='index.asp'><i class='bi bi-house me-1'></i>Home</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=product&action=list'><i class='bi bi-box me-1'></i>Products</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=home&action=about'><i class='bi bi-info-circle me-1'></i>About</a></li>" & vbCrLf
    Response.Write "                </ul>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </nav>" & vbCrLf
    Response.Write "    <main class='py-4'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <div class='row'>" & vbCrLf
    Response.Write "                <div class='col-md-8'>" & vbCrLf
    Response.Write "                    <div class='card shadow-sm'>" & vbCrLf
    Response.Write "                        <div class='card-header bg-primary text-white'>" & vbCrLf
    Response.Write "                            <h3 class='card-title mb-0'><i class='bi bi-plus-circle me-2'></i>Create New Product</h3>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                        <div class='card-body'>" & vbCrLf
    Response.Write "                            <form method='post' action='?controller=product&action=save'>" & vbCrLf
    Response.Write "                                <div class='mb-3'>" & vbCrLf
    Response.Write "                                    <label for='name' class='form-label'><i class='bi bi-tag me-1'></i>Product Name</label>" & vbCrLf
    Response.Write "                                    <input type='text' class='form-control' id='name' name='name' placeholder='e.g. Laptop' required>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                                <div class='mb-3'>" & vbCrLf
    Response.Write "                                    <label for='description' class='form-label'><i class='bi bi-file-text me-1'></i>Description</label>" & vbCrLf
    Response.Write "                                    <textarea class='form-control' id='description' name='description' rows='4' placeholder='Product description...'></textarea>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                                <div class='row'>" & vbCrLf
    Response.Write "                                    <div class='col-md-6'>" & vbCrLf
    Response.Write "                                        <div class='mb-3'>" & vbCrLf
    Response.Write "                                            <label for='price' class='form-label'><i class='bi bi-currency-dollar me-1'></i>Price</label>" & vbCrLf
    Response.Write "                                            <input type='number' class='form-control' id='price' name='price' step='0.01' min='0' placeholder='0.00' required>" & vbCrLf
    Response.Write "                                        </div>" & vbCrLf
    Response.Write "                                    </div>" & vbCrLf
    Response.Write "                                    <div class='col-md-6'>" & vbCrLf
    Response.Write "                                        <div class='mb-3'>" & vbCrLf
    Response.Write "                                            <label for='quantity' class='form-label'><i class='bi bi-stack me-1'></i>Quantity</label>" & vbCrLf
    Response.Write "                                            <input type='number' class='form-control' id='quantity' name='quantity' min='0' placeholder='0'>" & vbCrLf
    Response.Write "                                        </div>" & vbCrLf
    Response.Write "                                    </div>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                                <div class='d-grid gap-2 d-md-flex'>" & vbCrLf
    Response.Write "                                    <button type='submit' class='btn btn-primary'><i class='bi bi-check-circle me-1'></i>Create Product</button>" & vbCrLf
    Response.Write "                                    <a href='?controller=product&action=list' class='btn btn-secondary'><i class='bi bi-arrow-left me-1'></i>Cancel</a>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                            </form>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                    </div>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </main>" & vbCrLf
    Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
    Response.Write "        <div class='container text-center'>" & vbCrLf
    Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample</p>" & vbCrLf
    Response.Write "            <small>Built with ASPpy</small>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </footer>" & vbCrLf
    Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
    Response.Write "</body>" & vbCrLf
    Response.Write "</html>" & vbCrLf
End Sub

Sub ActionEdit()
    itemId = Request.QueryString("id")
    
    If itemId = "" Then
        Response.Redirect "?controller=product&action=list"
        Exit Sub
    End If
    
    Set itemObj = dbModel.GetByID(itemId)
    
    If itemObj Is Nothing Then
        Response.Write "<!DOCTYPE html>" & vbCrLf
        Response.Write "<html lang='en'>" & vbCrLf
        Response.Write "<head>" & vbCrLf
        Response.Write "    <meta charset='utf-8'>" & vbCrLf
        Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
        Response.Write "    <title>Product Not Found - ASPpy MVC</title>" & vbCrLf
        Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
        Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
        Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; }</style>" & vbCrLf
        Response.Write "</head>" & vbCrLf
        Response.Write "<body>" & vbCrLf
        Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
        Response.Write "        <div class='container'>" & vbCrLf
        Response.Write "            <a class='navbar-brand' href='index.asp'><i class='bi bi-gear-fill me-2'></i>ASPpy MVC</a>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </nav>" & vbCrLf
        Response.Write "    <main class='py-4'>" & vbCrLf
        Response.Write "        <div class='container'>" & vbCrLf
        Response.Write "            <div class='alert alert-danger'><i class='bi bi-exclamation-triangle me-2'></i>Product not found.</div>" & vbCrLf
        Response.Write "            <a href='?controller=product&action=list' class='btn btn-primary'><i class='bi bi-arrow-left me-1'></i>Back to Products</a>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </main>" & vbCrLf
        Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
        Response.Write "        <div class='container text-center'>" & vbCrLf
        Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample</p>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </footer>" & vbCrLf
        Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
        Response.Write "</body>" & vbCrLf
        Response.Write "</html>" & vbCrLf
        Exit Sub
    End If
    
    Response.Write "<!DOCTYPE html>" & vbCrLf
    Response.Write "<html lang='en'>" & vbCrLf
    Response.Write "<head>" & vbCrLf
    Response.Write "    <meta charset='utf-8'>" & vbCrLf
    Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
    Response.Write "    <title>Edit " & HtmlEncode(itemObj.Name) & " - ASPpy MVC</title>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; }</style>" & vbCrLf
    Response.Write "</head>" & vbCrLf
    Response.Write "<body>" & vbCrLf
    Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <a class='navbar-brand' href='index.asp'><i class='bi bi-gear-fill me-2'></i>ASPpy MVC</a>" & vbCrLf
    Response.Write "            <button class='navbar-toggler' type='button' data-bs-toggle='collapse' data-bs-target='#mainNav'><span class='navbar-toggler-icon'></span></button>" & vbCrLf
    Response.Write "            <div class='collapse navbar-collapse' id='mainNav'>" & vbCrLf
    Response.Write "                <ul class='navbar-nav ms-auto'>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='index.asp'><i class='bi bi-house me-1'></i>Home</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=product&action=list'><i class='bi bi-box me-1'></i>Products</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=home&action=about'><i class='bi bi-info-circle me-1'></i>About</a></li>" & vbCrLf
    Response.Write "                </ul>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </nav>" & vbCrLf
    Response.Write "    <main class='py-4'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <div class='row'>" & vbCrLf
    Response.Write "                <div class='col-md-8'>" & vbCrLf
    Response.Write "                    <div class='card shadow-sm'>" & vbCrLf
    Response.Write "                        <div class='card-header bg-warning text-dark'>" & vbCrLf
    Response.Write "                            <h3 class='card-title mb-0'><i class='bi bi-pencil-square me-2'></i>Edit Product</h3>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                        <div class='card-body'>" & vbCrLf
    Response.Write "                            <form method='post' action='?controller=product&action=update'>" & vbCrLf
    Response.Write "                                <input type='hidden' name='id' value='" & itemObj.ID & "'>" & vbCrLf
    Response.Write "                                <div class='mb-3'>" & vbCrLf
    Response.Write "                                    <label for='name' class='form-label'><i class='bi bi-tag me-1'></i>Product Name</label>" & vbCrLf
    Response.Write "                                    <input type='text' class='form-control' id='name' name='name' value='" & HtmlEncode(itemObj.Name) & "' required>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                                <div class='mb-3'>" & vbCrLf
    Response.Write "                                    <label for='description' class='form-label'><i class='bi bi-file-text me-1'></i>Description</label>" & vbCrLf
    Response.Write "                                    <textarea class='form-control' id='description' name='description' rows='4'>" & HtmlEncode(itemObj.Description) & "</textarea>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                                <div class='row'>" & vbCrLf
    Response.Write "                                    <div class='col-md-6'>" & vbCrLf
    Response.Write "                                        <div class='mb-3'>" & vbCrLf
    Response.Write "                                            <label for='price' class='form-label'><i class='bi bi-currency-dollar me-1'></i>Price</label>" & vbCrLf
    Response.Write "                                            <input type='number' class='form-control' id='price' name='price' step='0.01' min='0' value='" & itemObj.Price & "' required>" & vbCrLf
    Response.Write "                                        </div>" & vbCrLf
    Response.Write "                                    </div>" & vbCrLf
    Response.Write "                                    <div class='col-md-6'>" & vbCrLf
    Response.Write "                                        <div class='mb-3'>" & vbCrLf
    Response.Write "                                            <label for='quantity' class='form-label'><i class='bi bi-stack me-1'></i>Quantity</label>" & vbCrLf
    Response.Write "                                            <input type='number' class='form-control' id='quantity' name='quantity' min='0' value='" & itemObj.Quantity & "'>" & vbCrLf
    Response.Write "                                        </div>" & vbCrLf
    Response.Write "                                    </div>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                                <div class='d-grid gap-2 d-md-flex'>" & vbCrLf
    Response.Write "                                    <button type='submit' class='btn btn-warning'><i class='bi bi-check-circle me-1'></i>Update Product</button>" & vbCrLf
    Response.Write "                                    <a href='?controller=product&action=view&id=" & itemObj.ID & "' class='btn btn-secondary'><i class='bi bi-arrow-left me-1'></i>Cancel</a>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                            </form>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                    </div>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </main>" & vbCrLf
    Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
    Response.Write "        <div class='container text-center'>" & vbCrLf
    Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample</p>" & vbCrLf
    Response.Write "            <small>Built with ASPpy</small>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </footer>" & vbCrLf
    Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
    Response.Write "</body>" & vbCrLf
    Response.Write "</html>" & vbCrLf
End Sub

Sub ActionSave()
    Dim method
    method = Request.ServerVariables("REQUEST_METHOD")
    
    If method <> "POST" Then
        Response.Redirect "?controller=product&action=create"
        Exit Sub
    End If
    
    itemName = Request.Form("name")
    itemDesc = Request.Form("description")
    itemPrice = Request.Form("price")
    itemQty = Request.Form("quantity")
    
    If itemName = "" Or itemPrice = "" Then
        Response.Write "<h1>Validation Error</h1><p>Name and Price required.</p>"
        Exit Sub
    End If
    
    itemId = dbModel.Add(itemName, itemDesc, itemPrice, itemQty)
    Response.Redirect "?controller=product&action=view&id=" & itemId
End Sub

Sub ActionUpdate()
    Dim method
    method = Request.ServerVariables("REQUEST_METHOD")
    
    If method <> "POST" Then
        Response.Redirect "?controller=product&action=list"
        Exit Sub
    End If
    
    itemId = Request.Form("id")
    itemName = Request.Form("name")
    itemDesc = Request.Form("description")
    itemPrice = Request.Form("price")
    itemQty = Request.Form("quantity")
    
    If itemName = "" Or itemPrice = "" Then
        Response.Write "<h1>Validation Error</h1>"
        Exit Sub
    End If
    
    dbModel.Update itemId, itemName, itemDesc, itemPrice, itemQty
    Response.Redirect "?controller=product&action=view&id=" & itemId
End Sub

Sub ActionDelete()
    itemId = Request.QueryString("id")
    
    If itemId = "" Then
        Response.Redirect "?controller=product&action=list"
        Exit Sub
    End If
    
    Set itemObj = dbModel.GetByID(itemId)
    
    If itemObj Is Nothing Then
        Response.Write "<!DOCTYPE html>" & vbCrLf
        Response.Write "<html lang='en'>" & vbCrLf
        Response.Write "<head>" & vbCrLf
        Response.Write "    <meta charset='utf-8'>" & vbCrLf
        Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
        Response.Write "    <title>Product Not Found - ASPpy MVC</title>" & vbCrLf
        Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
        Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
        Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; }</style>" & vbCrLf
        Response.Write "</head>" & vbCrLf
        Response.Write "<body>" & vbCrLf
        Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
        Response.Write "        <div class='container'>" & vbCrLf
        Response.Write "            <a class='navbar-brand' href='index.asp'><i class='bi bi-gear-fill me-2'></i>ASPpy MVC</a>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </nav>" & vbCrLf
        Response.Write "    <main class='py-4'>" & vbCrLf
        Response.Write "        <div class='container'>" & vbCrLf
        Response.Write "            <div class='alert alert-danger'><i class='bi bi-exclamation-triangle me-2'></i>Product not found.</div>" & vbCrLf
        Response.Write "            <a href='?controller=product&action=list' class='btn btn-primary'><i class='bi bi-arrow-left me-1'></i>Back to Products</a>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </main>" & vbCrLf
        Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
        Response.Write "        <div class='container text-center'>" & vbCrLf
        Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample</p>" & vbCrLf
        Response.Write "        </div>" & vbCrLf
        Response.Write "    </footer>" & vbCrLf
        Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
        Response.Write "</body>" & vbCrLf
        Response.Write "</html>" & vbCrLf
        Exit Sub
    End If
    
    Response.Write "<!DOCTYPE html>" & vbCrLf
    Response.Write "<html lang='en'>" & vbCrLf
    Response.Write "<head>" & vbCrLf
    Response.Write "    <meta charset='utf-8'>" & vbCrLf
    Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
    Response.Write "    <title>Delete " & HtmlEncode(itemObj.Name) & " - ASPpy MVC</title>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; }</style>" & vbCrLf
    Response.Write "</head>" & vbCrLf
    Response.Write "<body>" & vbCrLf
    Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <a class='navbar-brand' href='index.asp'><i class='bi bi-gear-fill me-2'></i>ASPpy MVC</a>" & vbCrLf
    Response.Write "            <button class='navbar-toggler' type='button' data-bs-toggle='collapse' data-bs-target='#mainNav'><span class='navbar-toggler-icon'></span></button>" & vbCrLf
    Response.Write "            <div class='collapse navbar-collapse' id='mainNav'>" & vbCrLf
    Response.Write "                <ul class='navbar-nav ms-auto'>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='index.asp'><i class='bi bi-house me-1'></i>Home</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=product&action=list'><i class='bi bi-box me-1'></i>Products</a></li>" & vbCrLf
    Response.Write "                    <li class='nav-item'><a class='nav-link' href='?controller=home&action=about'><i class='bi bi-info-circle me-1'></i>About</a></li>" & vbCrLf
    Response.Write "                </ul>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </nav>" & vbCrLf
    Response.Write "    <main class='py-4'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <div class='row'>" & vbCrLf
    Response.Write "                <div class='col-md-6'>" & vbCrLf
    Response.Write "                    <div class='card shadow-sm border-danger'>" & vbCrLf
    Response.Write "                        <div class='card-header bg-danger text-white'>" & vbCrLf
    Response.Write "                            <h3 class='card-title mb-0'><i class='bi bi-exclamation-triangle me-2'></i>Confirm Delete</h3>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                        <div class='card-body'>" & vbCrLf
    Response.Write "                            <p class='lead'>Are you sure you want to delete this product?</p>" & vbCrLf
    Response.Write "                            <div class='alert alert-info'>" & vbCrLf
    Response.Write "                                <strong>" & HtmlEncode(itemObj.Name) & "</strong><br>" & vbCrLf
    Response.Write "                                <small class='text-muted'>$" & CStr(CDbl(itemObj.Price)) & "</small>" & vbCrLf
    Response.Write "                            </div>" & vbCrLf
    Response.Write "                            <p class='text-warning'><i class='bi bi-exclamation-circle me-1'></i>This action cannot be undone.</p>" & vbCrLf
    Response.Write "                            <form method='post' action='?controller=product&action=remove'>" & vbCrLf
    Response.Write "                                <input type='hidden' name='id' value='" & itemId & "'>" & vbCrLf
    Response.Write "                                <div class='d-grid gap-2'>" & vbCrLf
    Response.Write "                                    <button type='submit' class='btn btn-danger btn-lg'><i class='bi bi-trash me-1'></i>Yes, Delete Product</button>" & vbCrLf
    Response.Write "                                    <a href='?controller=product&action=view&id=" & itemId & "' class='btn btn-secondary btn-lg'><i class='bi bi-arrow-left me-1'></i>No, Cancel</a>" & vbCrLf
    Response.Write "                                </div>" & vbCrLf
    Response.Write "                            </form>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                    </div>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </main>" & vbCrLf
    Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
    Response.Write "        <div class='container text-center'>" & vbCrLf
    Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample</p>" & vbCrLf
    Response.Write "            <small>Built with ASPpy</small>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </footer>" & vbCrLf
    Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
    Response.Write "</body>" & vbCrLf
    Response.Write "</html>" & vbCrLf
End Sub

Sub ActionRemove()
    Dim method
    method = Request.ServerVariables("REQUEST_METHOD")
    
    If method <> "POST" Then
        Response.Redirect "?controller=product&action=list"
        Exit Sub
    End If
    
    itemId = Request.Form("id")
    dbModel.Delete itemId
    Response.Redirect "?controller=product&action=list"
End Sub

%>
