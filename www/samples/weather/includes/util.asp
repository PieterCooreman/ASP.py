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

Function GetTimestamp()
    GetTimestamp = Now()
End Function

Function GetWalkingSpeed(speed)
    Select Case LCase(speed)
        Case "slow"
            GetWalkingSpeed = 4.0
        Case "fast"
            GetWalkingSpeed = 6.5
        Case Else
            GetWalkingSpeed = 5.0
    End Select
End Function

Function GetSpeedLabel(speed)
    Select Case LCase(speed)
        Case "slow"
            GetSpeedLabel = "slow (4 km/h)"
        Case "fast"
            GetSpeedLabel = "fast (6.5 km/h)"
        Case Else
            GetSpeedLabel = "normal (5 km/h)"
    End Select
End Function

Function GetRainIntensity(precipitation)
    If precipitation = 0 Then
        GetRainIntensity = "dry"
    ElseIf precipitation < 0.5 Then
        GetRainIntensity = "drizzle"
    ElseIf precipitation < 2.5 Then
        GetRainIntensity = "moderate"
    Else
        GetRainIntensity = "heavy"
    End If
End Function

Function GetRainEmoji(intensity)
    Select Case intensity
        Case "dry"
            GetRainEmoji = "🟢"
        Case "drizzle"
            GetRainEmoji = "🟡"
        Case "moderate"
            GetRainEmoji = "🟠"
        Case "heavy"
            GetRainEmoji = "🔴"
        Case Else
            GetRainEmoji = "🟢"
    End Select
End Function

Function GenerateVerdict(waypoints)
    Dim totalPoints, dryPoints, rainPoints, i, verdict
    totalPoints = UBound(waypoints) + 1
    dryPoints = 0
    rainPoints = 0
    
    For i = 0 To UBound(waypoints)
        If waypoints(i)(4) = "dry" Then
            dryPoints = dryPoints + 1
        Else
            rainPoints = rainPoints + 1
        End If
    Next
    
    If rainPoints = 0 Then
        verdict = "Great news — your walk looks completely dry. No umbrella needed!"
    ElseIf dryPoints > rainPoints Then
        Dim rainStart, rainEnd, rainDuration
        rainStart = -1
        rainEnd = -1
        For i = 0 To UBound(waypoints)
            If waypoints(i)(4) <> "dry" And rainStart = -1 Then
                rainStart = i
            End If
            If waypoints(i)(4) <> "dry" Then
                rainEnd = i
            End If
        Next
        
        If rainEnd < totalPoints / 3 Then
            verdict = "You'll stay dry for most of your walk. Light rain expected in the last " & (totalPoints - rainEnd) & " minutes."
        ElseIf rainStart < totalPoints / 3 Then
            verdict = "Light rain expected early on, but you'll stay dry for most of your walk after minute " & rainEnd & "."
        Else
            verdict = "You'll stay dry for about " & rainStart & " minutes. Rain likely from minute " & (rainStart + 1) & " to " & (rainEnd + 1) & ". Dry again after that."
        End If
    ElseIf rainPoints > dryPoints * 2 Then
        verdict = "Rain likely for most of your walk. Umbrella recommended!"
    Else
        verdict = "Expect some rain along your route. Bring an umbrella or light jacket."
    End If
    
    GenerateVerdict = verdict
End Function

Function FormatDuration(minutes)
    If minutes < 1 Then
        FormatDuration = "less than a minute"
    ElseIf minutes = 1 Then
        FormatDuration = "1 minute"
    ElseIf minutes < 60 Then
        FormatDuration = minutes & " minutes"
    Else
        FormatDuration = Round(minutes / 60, 1) & " hours"
    End If
End Function
%>
