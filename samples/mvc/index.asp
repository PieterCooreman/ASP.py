<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%><%
'================================================================================
' index.asp - MVC Router/Dispatcher
' Entry point for all requests - routes to appropriate controller
'================================================================================

const dbPath = server.mappath("data/app.db")    

' Get the action parameter from query string
Dim action, controller, method
Dim controllerPath, controllerInc

action = Request.QueryString("action")
controller = Request.QueryString("controller")
method = Request.QueryString("method")

' Default values
If action = "" Then action = "index"
If controller = "" Then controller = "home"
If method = "" Then method = "GET"

' Normalize controller name
controller = LCase(controller)

' Build virtual path to controller file
Dim controllerVPath
controllerVPath = "controllers/" & controller & ".asp"

' Security check: prevent directory traversal
If InStr(controllerVPath, "..") > 0 Then
    Response.Status = "403 Forbidden"
    Response.Write "Access denied"
    Response.End()
End If

' Try to execute controller
Dim fso
Set fso = Server.CreateObject("Scripting.FileSystemObject")

' Physical path for validation only
controllerPath = Server.MapPath(controllerVPath)

If Not fso.FileExists(controllerPath) Then
    ' Default to home controller
    controller = "home"
    controllerVPath = "controllers/home.asp"
    controllerPath = Server.MapPath(controllerVPath)
End If

Set fso = Nothing

' Include the controller
On Error Resume Next
Server.Execute(controllerVPath)

If Err.Number <> 0 Then
    Response.Status = "500 Internal Server Error"
    Response.Write "<h1>Error</h1>"
    Response.Write "<p>Error: " & Err.Description & "</p>"
    Response.Write "<p>Controller: " & controller & "</p>"
    Response.Write "<p>Action: " & action & "</p>"
End If

On Error Goto 0
Set fso = Nothing
%>
