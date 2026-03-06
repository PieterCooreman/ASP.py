<%
'================================================================================
' utils.asp - Utility functions for controllers
'================================================================================

' Global variable to hold view data
Dim ViewData

' Render HTML header/layout
Sub RenderHeader()
    Response.Write "<!DOCTYPE html>" & vbCrLf
    Response.Write "<html lang='en'>" & vbCrLf
    Response.Write "<head>" & vbCrLf
    Response.Write "    <meta charset='utf-8'>" & vbCrLf
    Response.Write "    <meta name='viewport' content='width=device-width, initial-scale=1'>" & vbCrLf
    Response.Write "    <title>" & GetAppName() & " - ASPpy MVC</title>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <link href='https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.0/font/bootstrap-icons.min.css' rel='stylesheet'>" & vbCrLf
    Response.Write "    <style>" & vbCrLf
    Response.Write "        body { display: flex; flex-direction: column; min-height: 100vh; }" & vbCrLf
    Response.Write "        main { flex: 1; }" & vbCrLf
    Response.Write "        .navbar-brand { font-weight: 700; letter-spacing: 0.5px; }" & vbCrLf
    Response.Write "    </style>" & vbCrLf
    Response.Write "</head>" & vbCrLf
    Response.Write "<body>" & vbCrLf
    
    ' Navigation
    Response.Write "    <nav class='navbar navbar-expand-lg navbar-dark bg-dark'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
    Response.Write "            <a class='navbar-brand' href='index.asp'>" & vbCrLf
    Response.Write "                <i class='bi bi-gear-fill me-2'></i>" & GetAppName() & vbCrLf
    Response.Write "            </a>" & vbCrLf
    Response.Write "            <button class='navbar-toggler' type='button' data-bs-toggle='collapse' data-bs-target='#mainNav'>" & vbCrLf
    Response.Write "                <span class='navbar-toggler-icon'></span>" & vbCrLf
    Response.Write "            </button>" & vbCrLf
    Response.Write "            <div class='collapse navbar-collapse' id='mainNav'>" & vbCrLf
    Response.Write "                <ul class='navbar-nav ms-auto'>" & vbCrLf
    Response.Write "                    <li class='nav-item'>" & vbCrLf
    Response.Write "                        <a class='nav-link' href='index.asp'><i class='bi bi-house me-1'></i>Home</a>" & vbCrLf
    Response.Write "                    </li>" & vbCrLf
    Response.Write "                    <li class='nav-item'>" & vbCrLf
    Response.Write "                        <a class='nav-link' href='?controller=product&action=list'><i class='bi bi-box me-1'></i>Products</a>" & vbCrLf
    Response.Write "                    </li>" & vbCrLf
    Response.Write "                    <li class='nav-item'>" & vbCrLf
    Response.Write "                        <a class='nav-link' href='?controller=home&action=about'><i class='bi bi-info-circle me-1'></i>About</a>" & vbCrLf
    Response.Write "                    </li>" & vbCrLf
    Response.Write "                </ul>" & vbCrLf
    Response.Write "            </div>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </nav>" & vbCrLf
    
    Response.Write "    <main class='py-4'>" & vbCrLf
    Response.Write "        <div class='container'>" & vbCrLf
End Sub

' Render HTML footer
Sub RenderFooter()
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </main>" & vbCrLf
    
    Response.Write "    <footer class='bg-dark text-white-50 py-4 mt-5'>" & vbCrLf
    Response.Write "        <div class='container text-center'>" & vbCrLf
    Response.Write "            <p class='mb-1'>" & vbCrLf
    Response.Write "                <i class='bi bi-gear-fill me-1'></i>" & vbCrLf
    Response.Write "                " & GetAppName() & " v" & GetAppVersion() & vbCrLf
    Response.Write "            </p>" & vbCrLf
    Response.Write "            <small>ASPpy Classic ASP/VBScript → Python Transpiler</small>" & vbCrLf
    Response.Write "        </div>" & vbCrLf
    Response.Write "    </footer>" & vbCrLf
    
    Response.Write "    <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js'></script>" & vbCrLf
    Response.Write "</body>" & vbCrLf
    Response.Write "</html>" & vbCrLf
End Sub

' Render a view from the views folder
Sub RenderView(viewName, viewDataParam)
    ' Store data in global variable for view to access
    ' Handle both objects and primitives
    If IsObject(viewDataParam) Then
        Set ViewData = viewDataParam
    Else
        ViewData = viewDataParam
    End If
    
    ' Render header
    RenderHeader
    
    ' Use virtual path directly for Server.Execute
    Dim virtualPath
    virtualPath = "views/" & viewName & ".asp"
    
    ' Execute the view
    On Error Resume Next
    Server.Execute(virtualPath)
    If Err.Number <> 0 Then
        Response.Write "<div class='alert alert-danger'>" & vbCrLf
        Response.Write "<h4>Error Loading View: " & viewName & "</h4>" & vbCrLf
        Response.Write "<p>" & Err.Description & "</p>" & vbCrLf
        Response.Write "</div>" & vbCrLf
    End If
    On Error Goto 0
    
    ' Render footer
    RenderFooter
End Sub

' Redirect to another action
Sub Redirect(controller, action)
    Dim url
    url = "?controller=" & controller & "&action=" & action
    Response.Redirect(url)
End Sub

' URL encode a string
Function UrlEncode(str)
    UrlEncode = Server.URLEncode(str)
End Function

' HTML encode a string
Function HtmlEncode(str)
    HtmlEncode = Server.HTMLEncode(str)
End Function

' Check if user is logged in (from session)
Function IsLoggedIn()
    IsLoggedIn = Session("IsLoggedIn")
End Function

' Get logged-in user ID
Function GetUserID()
    GetUserID = Session("UserID")
End Function

' Get logged-in user name
Function GetUserName()
    GetUserName = Session("UserName")
End Function

' Increment page view counter
Sub IncrementPageViews()
    Application.Lock()
    Application("RequestCount") = Application("RequestCount") + 1
    Application.Unlock()
End Sub

' Get application name
Function GetAppName()
    GetAppName = Application("AppName")
End Function

' Get application version
Function GetAppVersion()
    GetAppVersion = Application("AppVersion")
End Function

%>
