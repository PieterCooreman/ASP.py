<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #include file="../includes/includes.asp" -->
<%
Response.CodePage = 65001
Response.Charset = "UTF-8"
Response.ContentType = "application/json"
Response.AddHeader "Access-Control-Allow-Origin", "*"

Dim db, pinSvc, pinId
Set db = New cls_db
db.Open
Set pinSvc = New cls_pin

pinId = Trim("" & Request.QueryString("id"))

If pinId = "" Then
    Response.Status = 400
    Response.Write "{""error"":""Missing pin id""}"
    db.Close: Set db = Nothing
    Response.End
End If

pinSvc.ReportPin db, pinId

Response.Write "{""success"":true}"

db.Close
Set db = Nothing
%>
