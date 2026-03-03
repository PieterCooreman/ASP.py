<%
Class cls_pin
    Public Function GetActivePins(db)
        Dim sql, rs
        sql = "SELECT * FROM pins WHERE expires_at > datetime('now') AND reports < 3 ORDER BY created_at DESC"
        Set rs = db.Query(sql)
        Set GetActivePins = rs
    End Function
    
    Public Function GetPinCount(db)
        GetPinCount = db.Scalar("SELECT COUNT(*) FROM pins WHERE expires_at > datetime('now') AND reports < 3", 0)
    End Function
    
    Public Function CreatePin(db, emoji, label, message, lat, lng)
        Dim id, deleteToken, createdAt, expiresAt, color, fuzzed(1), sql
        
        id = GenerateUUID()
        deleteToken = GenerateUUID()
        createdAt = GetTimestamp()
        expiresAt = AddHours(createdAt, 2)
        color = GetVibeColor(emoji)
        
        fuzzed = FuzzLocation(CDbl(lat), CDbl(lng))
        
        sql = "INSERT INTO pins (id, emoji, label, message, lat, lng, created_at, expires_at, color, delete_token, reports) VALUES ('" & _
            Q(id) & "', '" & Q(emoji) & "', '" & Q(label) & "', '" & Q(message) & "', " & _
            fuzzed(0) & ", " & fuzzed(1) & ", '" & Q(createdAt) & "', '" & Q(expiresAt) & "', '" & _
            Q(color) & "', '" & Q(deleteToken) & "', 0)"
        
        db.Execute sql
        
        CreatePin = Array(id, deleteToken)
    End Function
    
    Public Function DeletePin(db, id, deleteToken)
        Dim sql
        sql = "DELETE FROM pins WHERE id = '" & Q(id) & "' AND delete_token = '" & Q(deleteToken) & "'"
        db.Execute sql
    End Function
    
    Public Function GetPinById(db, id)
        Dim sql, rs
        sql = "SELECT * FROM pins WHERE id = '" & Q(id) & "'"
        Set rs = db.Query(sql)
        Set GetPinById = rs
    End Function
    
    Public Function ReportPin(db, id)
        Dim sql
        sql = "UPDATE pins SET reports = reports + 1 WHERE id = '" & Q(id) & "'"
        db.Execute sql
    End Function
    
    Public Sub CleanupExpired(db)
        db.Execute "DELETE FROM pins WHERE expires_at <= datetime('now')"
    End Sub
    
    Public Function CheckRateLimit(db, ip)
        Dim windowStart, currentCount
        windowStart = DateAdd("h", -1, Now())
        
        Dim existingCount
        existingCount = db.Scalar("SELECT COUNT(*) FROM rate_limits WHERE ip = '" & Q(ip) & "' AND window_start > '" & Q(windowStart) & "'", 0)
        
        If existingCount >= 3 Then
            CheckRateLimit = False
        Else
            db.Execute "INSERT OR REPLACE INTO rate_limits (ip, count, window_start) VALUES ('" & Q(ip) & "', " & (existingCount + 1) & ", datetime('now'))"
            CheckRateLimit = True
        End If
    End Function
End Class
%>
