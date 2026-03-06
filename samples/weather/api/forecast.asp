<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #include file="../includes/util.asp" -->
<%
Response.CodePage = 65001
Response.Charset = "UTF-8"
Response.ContentType = "application/json"
Response.AddHeader "Access-Control-Allow-Origin", "*"
Response.AddHeader "Access-Control-Allow-Methods", "POST, OPTIONS"
Response.AddHeader "Access-Control-Allow-Headers", "Content-Type"

If Request.ServerVariables("REQUEST_METHOD") = "OPTIONS" Then
    Response.End
End If

If Not IsPost() Then
    Response.Status = 405
    Response.Write "{""error"":""Method not allowed""}"
    Response.End
End If

Dim origin, destination, departureTime, speed, speedKmh
origin = Trim("" & Request.Form("origin"))
destination = Trim("" & Request.Form("destination"))
departureTime = Trim("" & Request.Form("departure_time"))
speed = Trim("" & Request.Form("speed"))

If origin = "" Or destination = "" Then
    Response.Status = 400
    Response.Write "{""error"":""Origin and destination are required""}"
    Response.End
End If

If departureTime = "" Then
    departureTime = "now"
End If

If speed = "" Then
    speed = "normal"
End If

speedKmh = GetWalkingSpeed(speed)

Dim originCoords(1), destCoords(1)

originCoords = GeocodeAddress(origin)
destCoords = GeocodeAddress(destination)

If originCoords(0) = 0 And originCoords(1) = 0 Then
    originCoords(0) = 40.7128
    originCoords(1) = -74.0060
End If

If destCoords(0) = 0 And destCoords(1) = 0 Then
    destCoords(0) = 40.7580
    destCoords(1) = -73.9855
End If

Dim distanceKm, totalMinutes
distanceKm = CalculateDistance(originCoords(0), originCoords(1), destCoords(0), destCoords(1))
totalMinutes = (distanceKm / speedKmh) * 60

Dim waypoints(), wpCount, i
wpCount = Int(totalMinutes / 2)
If wpCount < 5 Then wpCount = 5
If wpCount > 30 Then wpCount = 30

ReDim waypoints(wpCount - 1)

For i = 0 To wpCount - 1
    Dim lat, lng, eta, etaStr, precip, intensity
    Dim ratio
    ratio = i / (wpCount - 1)
    lat = originCoords(0) + (destCoords(0) - originCoords(0)) * ratio
    lng = originCoords(1) + (destCoords(1) - originCoords(1)) * ratio
    
    eta = DateAdd("n", i, Now())
    etaStr = Year(eta) & "-" & Right("0" & Month(eta), 2) & "-" & Right("0" & Day(eta), 2) & "T" & Right("0" & Hour(eta), 2) & ":" & Right("0" & Minute(eta), 2) & ":00"
    
    precip = GetSimulatedPrecipitation(lat, lng, eta)
    intensity = GetRainIntensity(precip)
    
    waypoints(i) = Array(lat, lng, etaStr, precip, intensity)
Next

Dim verdict
verdict = GenerateVerdict(waypoints)

Dim alternatives(), altCount
altCount = 3
ReDim alternatives(altCount - 1)

For i = 0 To altCount - 1
    Dim altMinutes, altVerdict, hasRain
    altMinutes = i * 10
    
    Dim altWaypoints(), awpCount, j
    awpCount = wpCount
    ReDim altWaypoints(awpCount - 1)
    
    hasRain = False
    For j = 0 To awpCount - 1
        Dim alat, alng, aeta, aetaStr, aprec, aintensity
        Dim aratio
        aratio = j / (awpCount - 1)
        alat = originCoords(0) + (destCoords(0) - originCoords(0)) * aratio
        alng = originCoords(1) + (destCoords(1) - originCoords(1)) * aratio
        
        aeta = DateAdd("n", altMinutes + j * 2, Now())
        aetaStr = Year(aeta) & "-" & Right("0" & Month(aeta), 2) & "-" & Right("0" & Day(aeta), 2) & "T" & Right("0" & Hour(aeta), 2) & ":" & Right("0" & Minute(aeta), 2) & ":00"
        
        aprec = GetSimulatedPrecipitation(alat, alng, aeta)
        aintensity = GetRainIntensity(aprec)
        
        altWaypoints(j) = Array(alat, alng, aetaStr, aprec, aintensity)
        
        If aintensity <> "dry" Then hasRain = True
    Next
    
    If hasRain Then
        altVerdict = "Rain expected — "
        Dim rwp
        For rwp = 0 To UBound(altWaypoints)
            If altWaypoints(rwp)(4) <> "dry" Then
                Exit For
            End If
        Next
        altVerdict = altVerdict & "light rain for ~" & (UBound(altWaypoints) - rwp + 1) & " min"
    Else
        altVerdict = "Completely dry walk"
    End If
    
    alternatives(i) = Array(altMinutes, altVerdict, hasRain)
Next

Response.Write "{"
Response.Write """origin"":{""lat"":" & originCoords(0) & ",""lng"":" & originCoords(1) & ",""name"":""" & H(origin) & """},"
Response.Write """destination"":{""lat"":" & destCoords(0) & ",""lng"":" & destCoords(1) & ",""name"":""" & H(destination) & """},"
Response.Write """distance"":" & Round(distanceKm, 1) & ","
Response.Write """duration"":" & Int(totalMinutes) & ","
Response.Write """speed"":""" & H(speed) & ""","
Response.Write """verdict"":""" & H(verdict) & ""","

Dim mainHasRain
mainHasRain = False
For i = 0 To UBound(waypoints)
    If waypoints(i)(4) <> "dry" Then
        mainHasRain = True
        Exit For
    End If
Next
Response.Write """has_rain"":" & LCase(mainHasRain) & ","
Response.Write """waypoints"":["

Dim wp
For i = 0 To UBound(waypoints)
    If i > 0 Then Response.Write ","
    Response.Write "{"
    Response.Write """lat"":" & waypoints(i)(0) & ","
    Response.Write """lng"":" & waypoints(i)(1) & ","
    Response.Write """eta"":""" & waypoints(i)(2) & ""","
    Response.Write """precipitation"":" & waypoints(i)(3) & ","
    Response.Write """intensity"":""" & waypoints(i)(4) & """"
    Response.Write "}"
Next

Response.Write "],"
Response.Write """alternatives"":["

For i = 0 To UBound(alternatives)
    If i > 0 Then Response.Write ","
    Response.Write "{"
    Response.Write """wait_minutes"":" & alternatives(i)(0) & ","
    Response.Write """verdict"":""" & H(alternatives(i)(1)) & ""","
    Response.Write """has_rain"":" & LCase(alternatives(i)(2))
    Response.Write "}"
Next

Response.Write "]"
Response.Write "}"

Function GeocodeAddress(address)
    Dim result(1)
    result(0) = 0
    result(1) = 0
    
    address = LCase(address)
    
    If InStr(address, "new york") > 0 Or InStr(address, "nyc") > 0 Then
        result(0) = 40.7128
        result(1) = -74.0060
    ElseIf InStr(address, "times square") > 0 Then
        result(0) = 40.7580
        result(1) = -73.9855
    ElseIf InStr(address, "central park") > 0 Then
        result(0) = 40.7829
        result(1) = -73.9654
    ElseIf InStr(address, "brooklyn") > 0 Then
        result(0) = 40.6782
        result(1) = -73.9442
    ElseIf InStr(address, "london") > 0 Then
        result(0) = 51.5074
        result(1) = -0.1278
    ElseIf InStr(address, "paris") > 0 Then
        result(0) = 48.8566
        result(1) = 2.3522
    ElseIf InStr(address, "tokyo") > 0 Then
        result(0) = 35.6762
        result(1) = 139.6503
    ElseIf InStr(address, "sydney") > 0 Then
        result(0) = -33.8688
        result(1) = 151.2093
    ElseIf InStr(address, "san francisco") > 0 Or InStr(address, "sf") > 0 Then
        result(0) = 37.7749
        result(1) = -122.4194
    End If
    
    GeocodeAddress = result
End Function

Function CalculateDistance(lat1, lng1, lat2, lng2)
    Dim dLat, dLng, a
    dLat = (lat2 - lat1) * 3.14159 / 180
    dLng = (lng2 - lng1) * 3.14159 / 180
    a = Sin(dLat / 2) * Sin(dLat / 2) + Cos(lat1 * 3.14159 / 180) * Cos(lat2 * 3.14159 / 180) * Sin(dLng / 2) * Sin(dLng / 2)
    CalculateDistance = 6371 * 2 * Sin(Sqr(a))
End Function

Function GetSimulatedPrecipitation(lat, lng, etaStr)
    Dim h, seed
    h = DatePart("h", Now())
    seed = Sin(lat * 100 + h) * Cos(lng * 100) * 10000
    
    Randomize
    Dim basePrecip
    basePrecip = (Rnd * 0.5)
    
    If h >= 12 And h <= 18 Then
        basePrecip = basePrecip + (Rnd * 1.5)
    End If
    
    If Int(Abs(seed)) Mod 3 = 0 Then
        basePrecip = basePrecip + (Rnd * 2)
    End If
    
    GetSimulatedPrecipitation = Round(basePrecip, 2)
End Function
%>
