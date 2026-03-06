<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #include file="utils.asp" -->
<%
'================================================================================
' home.asp - Home Controller
' Handles the home/dashboard page
'================================================================================

Dim action
action = Request.QueryString("action")

If action = "" Then action = "index"

Select Case LCase(action)
    Case "index"
        Call ActionIndex()
    Case "about"
        Call ActionAbout()
    Case Else
        Call ActionIndex()
End Select

'================================================================================
' ACTION: Dashboard/Home page
'================================================================================
Sub ActionIndex()
    Dim appName, appVersion
    appName = Application("AppName")
    appVersion = Application("AppVersion")
    
    Response.Write "<!DOCTYPE html>" & vbCrLf
    Response.Write "<html lang='en'>" & vbCrLf
    Response.Write "<head>" & vbCrLf
    Response.Write "    <meta charset='utf-8'>" & vbCrLf
    Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
    Response.Write "    <title>" & appName & " - ASPpy MVC</title>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; } .navbar-brand { font-weight: 700; }</style>" & vbCrLf
    Response.Write "</head>" & vbCrLf
    Response.Write "<body>" & vbCrLf
    
    ' Navigation
    Call RenderNav()
    
    Response.Write "    <main class='py-4'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <div class='bg-light py-5 rounded-3 mb-4'>" & vbCrLf
    Response.Write "                <h1 class='display-5 fw-bold'>Welcome to ASPpy MVC</h1>" & vbCrLf
    Response.Write "                <p class='lead'>This is a sample MVC application built with ASPpy.</p>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    
    Response.Write "            <div class='row g-4'>" & vbCrLf
    Response.Write "                <div class='col-md-6'>" & vbCrLf
    Response.Write "                    <div class='card h-100 shadow-sm'>" & vbCrLf
    Response.Write "                        <div class='card-body'>" & vbCrLf
    Response.Write "                            <h5 class='card-title'><i class='bi bi-star-fill text-warning me-2'></i>Features</h5>" & vbCrLf
    Response.Write "                            <ul class='list-unstyled'>" & vbCrLf
    Response.Write "                                <li><i class='bi bi-check-circle text-success me-2'></i>MVC Architecture</li>" & vbCrLf
    Response.Write "                                <li><i class='bi bi-check-circle text-success me-2'></i>Product Management</li>" & vbCrLf
    Response.Write "                                <li><i class='bi bi-check-circle text-success me-2'></i>SQLite Database</li>" & vbCrLf
    Response.Write "                                <li><i class='bi bi-check-circle text-success me-2'></i>Bootstrap 5 UI</li>" & vbCrLf
    Response.Write "                            </ul>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                    </div>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "                <div class='col-md-6'>" & vbCrLf
    Response.Write "                    <div class='card h-100 shadow-sm'>" & vbCrLf
    Response.Write "                        <div class='card-body'>" & vbCrLf
    Response.Write "                            <h5 class='card-title'><i class='bi bi-graph-up text-info me-2'></i>Statistics</h5>" & vbCrLf
    Response.Write "                            <p><strong>App Version:</strong> " & appVersion & "<br>" & vbCrLf
    Response.Write "                            <strong>Started At:</strong> " & Application("StartTime") & "<br>" & vbCrLf
    Response.Write "                            <strong>Requests:</strong> " & Application("RequestCount") & "</p>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                    </div>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    
    Response.Write "            <div class='alert alert-info mt-4'>" & vbCrLf
    Response.Write "                <i class='bi bi-lightbulb me-2'></i>" & vbCrLf
    Response.Write "                <strong>Quick Start:</strong> Head to the <a href='?controller=product&action=list' class='alert-link'>Products</a> section!" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </main>" & vbCrLf
    
    ' Footer
    Call RenderFooter()
End Sub

'================================================================================
' ACTION: About page
'================================================================================
Sub ActionAbout()
    Dim appName, appVersion
    appName = Application("AppName")
    appVersion = Application("AppVersion")
    
    Response.Write "<!DOCTYPE html>" & vbCrLf
    Response.Write "<html lang='en'>" & vbCrLf
    Response.Write "<head>" & vbCrLf
    Response.Write "    <meta charset='utf-8'>" & vbCrLf
    Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
    Response.Write "    <title>" & appName & " - About</title>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <style>body { display: flex; flex-direction: column; min-height: 100vh; } main { flex: 1; } .navbar-brand { font-weight: 700; }</style>" & vbCrLf
    Response.Write "</head>" & vbCrLf
    Response.Write "<body>" & vbCrLf
    
    ' Navigation
    Call RenderNav()
    
    Response.Write "    <main class='py-4'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <h1 class='mb-4'>About " & appName & "</h1>" & vbCrLf
    Response.Write "            <div class='row g-4'>" & vbCrLf
    Response.Write "                <div class='col-lg-8'>" & vbCrLf
    Response.Write "                    <div class='card shadow-sm mb-4'>" & vbCrLf
    Response.Write "                        <div class='card-body'>" & vbCrLf
    Response.Write "                            <h5 class='card-title'>What is ASPpy?</h5>" & vbCrLf
    Response.Write "                            <p>ASPpy is a Python-based runtime that executes Classic ASP (VBScript) pages. It provides compatibility with VBScript built-in functions and the Classic ASP object model.</p>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                    </div>" & vbCrLf
    Response.Write "                    <div class='card shadow-sm'>" & vbCrLf
    Response.Write "                        <div class='card-body'>" & vbCrLf
    Response.Write "                            <h5 class='card-title'>Key Features</h5>" & vbCrLf
    Response.Write "                            <ul>" & vbCrLf
    Response.Write "                                <li>MVC Architecture</li>" & vbCrLf
    Response.Write "                                <li>SQLite Database</li>" & vbCrLf
    Response.Write "                                <li>Product CRUD</li>" & vbCrLf
    Response.Write "                                <li>Bootstrap 5 UI</li>" & vbCrLf
    Response.Write "                                <li>Session Management</li>" & vbCrLf
    Response.Write "                            </ul>" & vbCrLf
    Response.Write "                        </div>" & vbCrLf
    Response.Write "                    </div>" & vbCrLf
    Response.Write "                </div>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </main>" & vbCrLf
    
    ' Footer
    Call RenderFooter()
End Sub

Sub RenderNav()
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
End Sub

Sub RenderFooter()
    Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
    Response.Write "        <div class='container text-center'>" & vbCrLf
    Response.Write "            <p class='mb-1'><i class='bi bi-gear-fill me-1'></i>ASPpy MVC Sample v" & Application("AppVersion") & "</p>" & vbCrLf
    Response.Write "            <small>Built with ASPpy - Classic ASP/VBScript → Python Transpiler</small>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </footer>" & vbCrLf
    Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
    Response.Write "</body>" & vbCrLf
    Response.Write "</html>" & vbCrLf
End Sub

%>
