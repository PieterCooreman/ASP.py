# ASPPY Project Generator Prompt

You are exploring a Classic ASP/VBScript → Python transpiler (ASPPY) located in `C:\ASPPY` (you have access to this folder and its subfolders). Your mission is to create a functional ASP web application using ASPPY.

The Python transpiler resides in `C:\ASPPY\ASPPY\*.py`

**Important Rule:** Do NOT modify any existing .py files in the `C:\ASPPY\ASPPY\` repository. No edits, no patches, no refactors.

---

## Core Rules for ASPPY Development

### Debugging & Error Visibility (CRITICAL)

- **Always check the browser for ASPPY error messages** - Don't assume silent failures
- **Never suppress errors broadly** with `On Error Resume Next` unless you specifically need to handle a known exception
- **It is BETTER to let errors raise during development** than to suppress them
- When you get an error:
  1. Read the full error message in the browser
  2. Note the line number and file path
  3. Check the file and fix the issue immediately
  4. Reload the page to verify the fix worked
  5. Do NOT move to next feature until current issue is resolved

**Proper error handling pattern:**
```vbscript
On Error Resume Next
Set conn = Server.CreateObject("ADODB.Connection")
If Err.Number <> 0 Then
    Response.Write "ERROR: Could not create connection: " & Err.Description
    Response.End()
End If
On Error Goto 0
```

**What NOT to do:**
```vbscript
' DON'T - This hides problems!
On Error Resume Next
Set conn = Server.CreateObject("ADODB.Connection")
' Missing error check - problem is invisible!
```

---

### Paths & Server.MapPath()

- `Server.MapPath(path)` converts a **virtual path** to a **physical file system path**
- Virtual path format: `data/app.db` (relative path, NO leading slash)
- Physical path format: `C:\ASPPY\www\samples\appname\data\app.db` (actual disk location)
- **Never hardcode paths** - always use `Server.MapPath()`
- **CRITICAL: Do NOT start paths with `/`** - This breaks when deploying app in a subfolder

**Why no leading slash?**
- Leading slash (`/data/app.db`) resolves to the web root, not your application folder
- Relative paths (`data/app.db`) resolve relative to the current application directory
- When deployed in a subfolder (e.g., `/myapps/myapp/`), relative paths still work correctly

**Correct usage:**
```vbscript
' Get database path (relative, no leading slash)
dbPath = Server.MapPath("data/app.db")
' Result in root: C:\ASPPY\www\data\app.db
' Result in subfolder: C:\ASPPY\www\myapps\myapp\data\app.db

' Get template path
templatePath = Server.MapPath("templates/email.html")
' Result in root: C:\ASPPY\www\templates\email.html
' Result in subfolder: C:\ASPPY\www\myapps\myapp\templates\email.html

' Check if file exists using physical path
Set fso = Server.CreateObject("Scripting.FileSystemObject")
If fso.FileExists(dbPath) Then
    ' File exists
End If
```

**Common mistakes to avoid:**
```vbscript
' ❌ DON'T - hardcoded path
dbPath = "C:\ASPPY\www\data\app.db"  ' Not portable!

' ❌ DON'T - leading slash (breaks in subfolders)
dbPath = Server.MapPath("/data/app.db")  ' Fails if deployed in subfolder!

' ✅ DO - relative path with no leading slash
dbPath = Server.MapPath("data/app.db")  ' Works everywhere!
```

---

### Database - SQLite with Pre-Initialization Strategy (CRITICAL)

**Never rely on application startup to create the database.** Always pre-create using Python.

#### Step 1: Create init_db.py Script
Create a Python script in your project root to initialize the database:

```python
#!/usr/bin/env python3
import sqlite3
import os

def init_database():
    # Create path relative to this script
    db_dir = 'www/samples/[appname]/data'
    db_path = os.path.join(db_dir, 'app.db')
    
    # Create directory if it doesn't exist
    os.makedirs(db_dir, exist_ok=True)
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Create tables
    cursor.execute('''CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')
    
    # Insert sample data if table is empty
    cursor.execute("SELECT COUNT(*) FROM users")
    if cursor.fetchone()[0] == 0:
        cursor.execute("INSERT INTO users (name, email) VALUES (?, ?)",
                      ('John Doe', 'john@example.com'))
    
    conn.commit()
    conn.close()
    print(f"✓ Database initialized: {db_path}")

if __name__ == "__main__":
    init_database()
```

#### Step 2: Run Before ASPPY Server
```bash
# 1. Initialize database (one-time setup)
python init_db.py

# 2. Start ASPPY server
python -m ASPPY.server 0.0.0.0 5000 www

# 3. Access application
# http://localhost:5000/samples/[appname]/
```

#### Step 3: Use in ASP Pages
Use ADODB.Connection to query the database:

```vbscript
Dim dbPath, conn, rs, sql

' Get database path (relative, no leading slash)
dbPath = Server.MapPath("data/app.db")

' Create connection
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Data Source=" & dbPath

' Execute query
sql = "SELECT * FROM users WHERE id = " & CInt(userId)
Set rs = conn.Execute(sql)

If Not rs.EOF Then
    Response.Write rs.Fields("name").Value
End If

rs.Close()
conn.Close()
```

#### SQLite Date/Time
Always use SQLite's `datetime('now')` instead of VBScript's `NOW()`:

```vbscript
' In SQL queries
sql = "UPDATE users SET updated_at = datetime('now') WHERE id = " & userId
```

---

### Global.asa - Use With Caution

- ASPPY has **limited support** for Global.asa
- **Do NOT use Global.asa for database initialization** - errors are silent
- **Do NOT use Global.asa for complex logic** - keep it simple
- **Instead use init_db.py for database setup**

If you must use Global.asa, keep it minimal:

```vbscript
Sub Application_OnStart()
    ' Simple variable initialization only
    Application("AppName") = "My App"
    Application("Version") = "1.0"
    ' Complex logic moved to init_db.py
End Sub

Sub Session_OnStart()
    ' Initialize session variables
    Session("IsLoggedIn") = False
    Session("UserId") = ""
End Sub
```

**What NOT to do in Global.asa:**
```vbscript
Sub Application_OnStart()
    On Error Resume Next
    ' DON'T - Database initialization (errors are silent!)
    Set dbConnection = CreateConnection()
End Sub
```

---

### Include Files - Path & Scope

- **Include syntax**: `<!--#include file="path/to/file.asp"-->`
- **Path is relative** to the file doing the include (not the main request)
- **Variable scope**: Variables declared in main page are accessible in included files
- **Place includes at TOP** of file if the included code is needed by later code
- **Avoid circular includes**: A includes B includes A causes infinite loop

**Correct usage:**
```vbscript
' index.asp includes utils.asp
<!--#include file="utils.asp"-->

<% 
' Now can use functions from utils.asp
Call LogEvent("Page loaded")
%>
```

---

### Response Output & Security

#### HTML Encoding (CRITICAL for Security)
**Always HTML-encode user input before displaying** to prevent XSS attacks:

```vbscript
' ❌ DON'T - XSS vulnerability!
Response.Write productName

' ✅ DO - HTML encode for safety
Response.Write Server.HTMLEncode(productName)
```

#### Response Structure
```vbscript
' Set content type for JSON responses
Response.ContentType = "application/json"
Response.Write "{""status"":""success""}"

' Set status codes
Response.Status = "401 Unauthorized"

' Stop processing
Response.End()

' Buffer large responses
Response.Buffer = True
' ... build response ...
Response.Flush()
```

#### Building Large HTML Blocks
For large HTML output, build in memory first to improve performance:

```vbscript
' Build HTML in memory
html = "<html>" & vbCrLf
html = html & "<head><title>Page</title></head>" & vbCrLf
html = html & "<body><p>Content</p></body>" & vbCrLf
html = html & "</html>" & vbCrLf
Response.Write html
```

---

## Development Workflow

1. **Initialize database**: `python init_db.py`
2. **Start ASPPY server**: `python -m ASPPY.server 0.0.0.0 5000 www`
3. **Test every page** in browser to screen for errors
4. **Fix errors immediately** - don't suppress with `On Error Resume Next`
5. **Verify fix worked** by reloading page
6. **Move to next feature** only after current issues are resolved

---

## Common Pitfalls to Avoid

### 1. Hardcoded Paths
```vbscript
' ❌ DON'T - hardcoded absolute path
dbPath = "C:\ASPPY\www\data\app.db"

' ❌ DON'T - leading slash (breaks in subfolders)
dbPath = Server.MapPath("/data/app.db")

' ✅ DO - relative path with no leading slash
dbPath = Server.MapPath("data/app.db")
```

### 2. Silent Error Suppression
```vbscript
' ❌ DON'T
On Error Resume Next
Set conn = CreateConnection()  ' If this fails, you won't know!

' ✅ DO
On Error Resume Next
Set conn = CreateConnection()
If Err.Number <> 0 Then
    Response.Write "ERROR: " & Err.Description
    Response.End()
End If
On Error Goto 0
```

### 3. Variable Name Collisions
```vbscript
' ❌ DON'T (conflicts with included files)
Dim name, id, status  ' Too generic!

' ✅ DO (use prefixes)
Dim productName, productId, productStatus
```

### 4. Forgetting to Create Directories
```vbscript
' ❌ DON'T (fails if data folder doesn't exist)
Set fso = Server.CreateObject("Scripting.FileSystemObject")
Set file = fso.CreateTextFile(Server.MapPath("data/log.txt"))

' ✅ DO (create folder first with relative path)
Set fso = Server.CreateObject("Scripting.FileSystemObject")
dataFolder = Server.MapPath("data")
If Not fso.FolderExists(dataFolder) Then
    fso.CreateFolder(dataFolder)
End If
Set file = fso.CreateTextFile(dataFolder & "\log.txt")
```

### 5. Not Checking Array Bounds
```vbscript
' ❌ DON'T (crashes if array is empty)
For i = 0 To UBound(results)
    Response.Write results(i)
Next

' ✅ DO (check first)
If IsArray(results) And UBound(results) >= 0 Then
    For i = 0 To UBound(results)
        Response.Write results(i)
    Next
End If
```

### 6. Not HTML Encoding User Input
```vbscript
' ❌ DON'T (XSS vulnerability!)
Response.Write productName

' ✅ DO (encode for safety)
Response.Write Server.HTMLEncode(productName)
```

### 7. Database Query String Concatenation Without Type Conversion
```vbscript
' ❌ DON'T (SQL injection risk)
sql = "SELECT * FROM users WHERE id = " & userId

' ✅ DO (force correct type)
sql = "SELECT * FROM users WHERE id = " & CInt(userId)
```

---

## Common Supported COM Objects

- `Scripting.Dictionary` - works
- `Scripting.FileSystemObject` - works
- `ADODB.Connection` - works for SQLite
- `VBScript.RegExp` - works
- `ADODB.Recordset` - works (use with ADODB.Connection)

---

## Testing & Verification Checklist

### Phase 1: Setup
- [ ] Database file created: `www/samples/[appname]/data/app.db`
- [ ] Run: `python init_db.py`
- [ ] Start ASPPY server: `python -m ASPPY.server 0.0.0.0 5000 www`
- [ ] Watch for startup errors in console

### Phase 2: Basic Testing
- [ ] Open browser to: `http://localhost:5000/samples/[appname]/`
- [ ] Verify page loads (no ASPPY error codes)
- [ ] Test main navigation
- [ ] Check that all links work

### Phase 3: Feature Testing
- [ ] Test all forms (create, edit, delete operations)
- [ ] Verify database changes persist (refresh page)
- [ ] Test error cases (missing fields, invalid input)
- [ ] Check response times (should be < 1 second)
- [ ] HTML encode all user output (no < or > characters in HTML)

### Phase 4: Final Check
- [ ] Stop server (Ctrl+C)
- [ ] Restart server: `python -m ASPPY.server 0.0.0.0 5000 www`
- [ ] Verify all pages still work
- [ ] Check for any memory leaks or file handle issues

### If You Encounter Errors
1. **Read the full error message** in browser
2. **Note the line number** where error occurred
3. **Check the file and line** in your code
4. **Make the fix**
5. **Reload browser** (Ctrl+R or Cmd+R)
6. **Verify fix worked**
7. **Move to next issue**

---

## Project Deliverables

1. **All ASP pages** in appropriate directory structure: `www/samples/[appname]/`
2. **Database schema SQL file**: `schema.sql`
3. **Python initialization script**: `init_db.py` (to create SQLite database)
4. **Working application** testable at: `http://localhost:5000/samples/[appname]/`
5. **Verification** that all pages load without ASPPY errors
6. **Documentation** of any issues encountered or workarounds used

---

## Resources & References

### ASPPY Wiki & Documentation
- Main Wiki: https://github.com/PieterCooreman/ASPPY/wiki
- VBScript Syntax: https://github.com/PieterCooreman/ASPPY/wiki/VBScript-Syntax
- Built-in Objects: https://github.com/PieterCooreman/ASPPY/wiki/Built-in-Objects
- IIS Deployment: https://github.com/PieterCooreman/ASPPY/wiki/Replacing-Classic-ASP-VBScript-by-ASPPY-in-IIS-(Advanced:-Best-of-Both-Worlds)

### Classic ASP/VBScript Documentation
- ADODB Connection: https://learn.microsoft.com/en-us/sql/ado/reference/ado-api/connection-object-ado
- VBScript Functions: https://learn.microsoft.com/en-us/previous-versions/t0aew7h6(v=vs.85)
- Regular Expressions: https://learn.microsoft.com/en-us/previous-versions/d6fed073(v=vs.85)

### SQLite
- SQLite Documentation: https://www.sqlite.org/docs.html
- Python sqlite3: https://docs.python.org/3/library/sqlite3.html
- Date/Time in SQLite: https://www.sqlite.org/lang_datefunc.html

### Security Best Practices
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- XSS Prevention: https://owasp.org/www-community/attacks/xss/
- SQL Injection: https://owasp.org/www-community/attacks/SQL_Injection
- Input Validation: https://owasp.org/www-community/controls/Input_Validation

---

## Additional Best Practices

### Response Buffer
Always include `Response.Buffer = True` at the top of pages that do redirects or heavy processing:

```vbscript
<%
Response.Buffer = True
' Page logic here
' ...
Response.Redirect "nextpage.asp"
%>
```

### Session Management
ASPPY supports `Session` and `Request.Cookies`:

```vbscript
' Set session variable
Session("UserId") = userId

' Check session variable
If Session("IsLoggedIn") = True Then
    Response.Write "Welcome back!"
End If

' Use unique cookie names to avoid conflicts
Response.Cookies("MyAppSessionId") = sessionId
```

### Error Codes Reference
Common ASPPY error codes:
- `80004005` - Unspecified error or runtime exception
- `800a000d` - Type mismatch (wrong data type)
- `800a0009` - Subscript out of range (array index invalid)
- `800a0411` - Name already in use (variable redeclaration)

When you see these errors, check:
- Data types (numbers vs strings)
- Array bounds before accessing
- Variable declarations (no redeclaration)
- Object creation with Server.CreateObject()

---

## Troubleshooting Guide

### Database Not Found Error
**Symptom**: "File not found: C:\ASPPY\www\samples\[appname]\data\app.db"

**Solution**:
1. Run `python init_db.py` first
2. Verify file exists in file system
3. Check that init_db.py is in project root
4. Check directory permissions

### Type Mismatch Error
**Symptom**: "Type mismatch: Expected X, got Y"

**Solution**:
1. Check variable type (CInt(), CStr(), CDbl() for conversion)
2. Verify database field returns expected type
3. Check form input types (form fields are always strings)

### Subscript Out of Range
**Symptom**: "Subscript out of range" when accessing array

**Solution**:
1. Check if array is empty: `If IsArray(arr) And UBound(arr) >= 0`
2. Don't assume database query returns results
3. Check loop bounds: `For i = 0 To UBound(arr)`

### Silent Failures
**Symptom**: Page appears to work but nothing happens

**Solution**:
1. Remove `On Error Resume Next` temporarily
2. Reload page in browser
3. Check for error messages
4. Fix the error
5. Re-add error handling if needed

---



## Final Notes

- **Always test before moving forward** - Don't ignore errors
- **Use Server.MapPath() consistently** - Never hardcode paths
- **Pre-create databases with Python** - Don't rely on ASP initialization
- **HTML-encode all user output** - Prevent XSS vulnerabilities
- **Check errors immediately** - Don't suppress and continue
- **Keep Global.asa minimal** - Complex logic belongs in separate scripts

**Happy coding with ASPPY!** 🚀
