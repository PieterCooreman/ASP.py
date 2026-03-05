<%
' About page
' Access ViewData from parent scope
%>
<h1 class="mb-4">About <%=GetAppName()%></h1>

<div class="row g-4">
    <div class="col-lg-8">
        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <h5 class="card-title">What is ASP4?</h5>
                <p>
                    ASP4 is a Python-based runtime that executes Classic ASP (VBScript) pages.
                    It provides compatibility with most VBScript built-in functions, the Classic ASP 
                    object model (Request, Response, Session, Application, Server), and various COM 
                    components commonly used in legacy ASP applications.
                </p>
                <p>
                    This sample application demonstrates how to build a modern MVC application 
                    using ASP4, with proper separation of concerns, database operations, and 
                    clean architecture patterns.
                </p>
            </div>
        </div>

        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <h5 class="card-title">Project Structure</h5>
                <pre><code>claude/
  ├── controllers/     # Request handlers (business logic)
  ├── models/          # Data models and database access
  ├── views/           # HTML templates
  ├── data/            # SQLite database
  ├── public/          # Static assets
  ├── Global.asa       # Application initialization
  └── index.asp        # MVC router/dispatcher</code></pre>
            </div>
        </div>

        <div class="card shadow-sm">
            <div class="card-body">
                <h5 class="card-title">Key Features</h5>
                <ul>
                    <li><strong>MVC Architecture:</strong> Clean separation of Models, Views, and Controllers</li>
                    <li><strong>SQLite Database:</strong> Lightweight, file-based database with ADODB support</li>
                    <li><strong>Product CRUD:</strong> Full Create, Read, Update, Delete operations</li>
                    <li><strong>Session Management:</strong> User session tracking and state management</li>
                    <li><strong>Responsive UI:</strong> Bootstrap 5 for modern, mobile-friendly interface</li>
                    <li><strong>Routing:</strong> Query string-based routing system</li>
                </ul>
            </div>
        </div>
    </div>

    <div class="col-lg-4">
        <div class="card bg-light shadow-sm sticky-top" style="top: 20px;">
            <div class="card-body">
                <h5 class="card-title">Quick Links</h5>
                <div class="btn-group-vertical w-100">
                    <a href="?controller=product&action=list" class="btn btn-outline-primary text-start">
                        <i class="bi bi-box me-2"></i>Product Catalog
                    </a>
                    <a href="?controller=product&action=create" class="btn btn-outline-primary text-start">
                        <i class="bi bi-plus-circle me-2"></i>Add New Product
                    </a>
                    <a href="?controller=home&action=index" class="btn btn-outline-primary text-start">
                        <i class="bi bi-house me-2"></i>Home
                    </a>
                </div>
            </div>
        </div>

        <div class="card shadow-sm mt-3">
            <div class="card-body small">
                <p class="mb-2">
                    <strong>Version:</strong> <%=GetAppVersion()%><br>
                    <strong>Framework:</strong> ASP4<br>
                    <strong>Database:</strong> SQLite<br>
                    <strong>UI Framework:</strong> Bootstrap 5
                </p>
            </div>
        </div>
    </div>
</div>
