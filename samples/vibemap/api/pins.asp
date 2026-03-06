<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #include file="../includes/includes.asp" -->
<%
Response.CodePage = 65001
Response.Charset = "UTF-8"
Response.ContentType = "application/json"
Response.AddHeader "Access-Control-Allow-Origin", "*"
Response.AddHeader "Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS"
Response.AddHeader "Access-Control-Allow-Headers", "Content-Type"

If Request.ServerVariables("REQUEST_METHOD") = "OPTIONS" Then
    Response.End
End If

Dim db, pinSvc, method
Set db = New cls_db
db.Open
Set pinSvc = New cls_pin

pinSvc.CleanupExpired db

method = UCase(Request.ServerVariables("REQUEST_METHOD"))

If method = "GET" Then
    Dim rs, pins(), i
    i = 0
    Set rs = pinSvc.GetActivePins(db)
    Do While Not rs.EOF
        ReDim Preserve pins(i)
        pins(i) = Array("" & rs("id"), "" & rs("emoji"), "" & rs("label"), "" & Nz(rs("message"), ""), _
            CDbl(rs("lat")), CDbl(rs("lng")), "" & rs("created_at"), "" & rs("color"), CInt(rs("reports")))
        rs.MoveNext
        i = i + 1
    Loop
    rs.Close
    Set rs = Nothing
    
    Dim json, j
    json = "["
    For j = 0 To i - 1
        If j > 0 Then json = json & ","
        json = json & "{"
        json = json & """id"":""" & H(pins(j)(0)) & ""","
        json = json & """emoji"":""" & H(pins(j)(1)) & ""","
        json = json & """label"":""" & H(pins(j)(2)) & ""","
        json = json & """message"":""" & H(pins(j)(3)) & ""","
        json = json & """lat"":" & pins(j)(4) & ","
        json = json & """lng"":" & pins(j)(5) & ","
        json = json & """created_at"":""" & H(pins(j)(6)) & ""","
        json = json & """color"":""" & H(pins(j)(7)) & ""","
        json = json & """reports"":" & pins(j)(8)
        json = json & "}"
    Next
    json = json & "]"
    
    Response.Write json
    
ElseIf method = "POST" Then
    Dim clientIP, canPost
    clientIP = GetClientIP()
    canPost = pinSvc.CheckRateLimit(db, clientIP)
    
    If Not canPost Then
        Response.Status = 429
        Response.Write "{""error"":""Rate limit exceeded. Max 3 pins per hour.""}"
        db.Close: Set db = Nothing
        Response.End
    End If
    
    Dim emoji, label, message, lat, lng
    emoji = Trim("" & Request.Form("emoji"))
    label = Trim("" & Request.Form("label"))
    message = Trim("" & Request.Form("message"))
    lat = Trim("" & Request.Form("lat"))
    lng = Trim("" & Request.Form("lng"))
    
    If emoji = "" Or label = "" Or lat = "" Or lng = "" Then
        Response.Status = 400
        Response.Write "{""error"":""Missing required fields""}"
        db.Close: Set db = Nothing
        Response.End
    End If
    
    If Len(message) > 80 Then
        message = Left(message, 80)
    End If
    
    If ContainsProfanity(message) Then
        Response.Status = 400
        Response.Write "{""error"":""Message contains inappropriate content""}"
        db.Close: Set db = Nothing
        Response.End
    End If
    
    Dim result
    result = pinSvc.CreatePin(db, emoji, label, message, lat, lng)
    
    Response.Write "{"
    Response.Write """id"":""" & H(result(0)) & ""","
    Response.Write """delete_token"":""" & H(result(1)) & """"
    Response.Write "}"
    
ElseIf method = "DELETE" Then
    Dim pinId, deleteToken
    pinId = Trim("" & Request.QueryString("id"))
    deleteToken = Trim("" & Request.QueryString("token"))
    
    If pinId = "" Or deleteToken = "" Then
        Response.Status = 400
        Response.Write "{""error"":""Missing id or token""}"
        db.Close: Set db = Nothing
        Response.End
    End If
    
    pinSvc.DeletePin db, pinId, deleteToken
    Response.Write "{""success"":true}"
    
Else
    Response.Status = 405
    Response.Write "{""error"":""Method not allowed""}"
End If

db.Close
Set db = Nothing
%>
