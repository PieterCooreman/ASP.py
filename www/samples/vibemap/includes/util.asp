<%
Function H(v)
    H = Server.HTMLEncode("" & v)
End Function

Function Q(v)
    Q = Replace("" & v, "'", "''")
End Function

Function Nz(v, fallback)
    If IsNull(v) Or IsEmpty(v) Then
        Nz = fallback
    Else
        Nz = v
    End If
End Function

Function ToInt(v, fallback)
    Dim s
    s = Trim("" & v)
    If s = "" Then
        ToInt = fallback
    ElseIf IsNumeric(s) Then
        ToInt = CLng(s)
    Else
        ToInt = fallback
    End If
End Function

Function IsPost()
    IsPost = (UCase("" & Request.ServerVariables("REQUEST_METHOD")) = "POST")
End Function

Function GetClientIP()
    Dim ip
    ip = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
    If ip = "" Then ip = Request.ServerVariables("REMOTE_ADDR")
    GetClientIP = Split(ip, ",")(0)
End Function

Function GenerateUUID()
    Dim obj, uuid
    Set obj = Server.CreateObject("Scripting.FileSystemObject")
    Randomize
    uuid = CreateGUID()
    GenerateUUID = LCase(uuid)
End Function

Function CreateGUID()
    Dim TypeLib, guid
    Set TypeLib = Server.CreateObject("Scripting.Dictionary")
    Randomize
    CreateGUID = "" & _
        Hex(Int(Rnd * 65535)) & "-" & _
        Hex(Int(Rnd * 65535)) & "-" & _
        Hex(Int(Rnd * 65535)) & "-" & _
        Hex(Int(Rnd * 65535)) & "-" & _
        Hex(Int(Rnd * 65535) * 65535)
End Function

Function GetTimestamp()
    GetTimestamp = Now()
End Function

Function AddHours(dt, hours)
    AddHours = DateAdd("h", hours, dt)
End Function

Function GetVibeColor(emoji)
    Select Case emoji
        Case "🔥"
            GetVibeColor = "#FF6B35"
        Case "😴"
            GetVibeColor = "#6B5B95"
        Case "🎵"
            GetVibeColor = "#88B04B"
        Case "💼"
            GetVibeColor = "#45B8AC"
        Case "🍕"
            GetVibeColor = "#EFC050"
        Case "✨"
            GetVibeColor = "#DD4124"
        Case "🧘"
            GetVibeColor = "#5B5EA6"
        Case "🥳"
            GetVibeColor = "#FF69B4"
        Case "😤"
            GetVibeColor = "#E15D44"
        Case "💭"
            GetVibeColor = "#9B2335"
        Case "😄"
            GetVibeColor = "#00A86B"
        Case "😢"
            GetVibeColor = "#6495ED"
        Case Else
            GetVibeColor = "#888888"
    End Select
End Function

Function GetVibes()
    Dim vibes(11)(1)
    vibes(0)(0) = "🔥": vibes(0)(1) = "On fire"
    vibes(1)(0) = "😴": vibes(1)(1) = "Sleepy"
    vibes(2)(0) = "🎵": vibes(2)(1) = "Vibing to music"
    vibes(3)(0) = "💼": vibes(3)(1) = "Working"
    vibes(4)(0) = "🍕": vibes(4)(1) = "Eating"
    vibes(5)(0) = "✨": vibes(5)(1) = "Inspired"
    vibes(6)(0) = "🧘": vibes(6)(1) = "Chill"
    vibes(7)(0) = "🥳": vibes(7)(1) = "Celebrating"
    vibes(8)(0) = "😤": vibes(8)(1) = "Frustrated"
    vibes(9)(0) = "💭": vibes(9)(1) = "Deep thinking"
    vibes(10)(0) = "😄": vibes(10)(1) = "Happy"
    vibes(11)(0) = "😢": vibes(11)(1) = "Sad"
    GetVibes = vibes
End Function

Function FuzzyTime(createdAt)
    Dim diff, minutes
    diff = Now() - CDate(createdAt)
    minutes = Round(diff * 24 * 60)
    
    If minutes < 1 Then
        FuzzyTime = "just now"
    ElseIf minutes < 60 Then
        FuzzyTime = minutes & " min ago"
    ElseIf minutes < 1440 Then
        FuzzyTime = Round(minutes / 60) & " hr ago"
    Else
        FuzzyTime = Round(minutes / 1440) & " days ago"
    End If
End Function

Function FuzzLocation(lat, lng)
    Dim fuzzLat, fuzzLng, radius
    radius = 0.02
    Randomize
    fuzzLat = lat + (Rnd - 0.5) * radius
    fuzzLng = lng + (Rnd - 0.5) * radius
    FuzzLocation = Array(fuzzLat, fuzzLng)
End Function

Function ContainsProfanity(text)
    Dim profanity(10)
    profanity(0) = "fuck"
    profanity(1) = "shit"
    profanity(2) = "ass"
    profanity(3) = "bitch"
    profanity(4) = "damn"
    profanity(5) = "hell"
    profanity(6) = "crap"
    profanity(7) = "dick"
    profanity(8) = "cock"
    profanity(9) = "piss"
    profanity(10) = "cunt"
    
    Dim i, lowerText
    lowerText = LCase(text)
    For i = 0 To UBound(profanity)
        If InStr(lowerText, profanity(i)) > 0 Then
            ContainsProfanity = True
            Exit Function
        End If
    Next
    ContainsProfanity = False
End Function
%>
