<%
' Home/Dashboard page
' Access ViewData from parent scope
%>
<div class="bg-light py-5 rounded-3 mb-4">
    <h1 class="display-5 fw-bold">Welcome to ASPpy MVC</h1>
    <p class="lead">
        This is a sample MVC application built with ASPpy, a Python-based
        runtime for Classic ASP (VBScript).
    </p>
</div>

<div class="row g-4">
    <!-- Features Card -->
    <div class="col-md-6">
        <div class="card h-100 shadow-sm">
            <div class="card-body">
                <h5 class="card-title">
                    <i class="bi bi-star-fill text-warning me-2"></i>Features
                </h5>
                <ul class="list-unstyled">
                    <li><i class="bi bi-check-circle text-success me-2"></i>MVC Architecture</li>
                    <li><i class="bi bi-check-circle text-success me-2"></i>Product Management</li>
                    <li><i class="bi bi-check-circle text-success me-2"></i>SQLite Database</li>
                    <li><i class="bi bi-check-circle text-success me-2"></i>Bootstrap 5 UI</li>
                    <li><i class="bi bi-check-circle text-success me-2"></i>Session Management</li>
                </ul>
            </div>
        </div>
    </div>

    <!-- Statistics Card -->
    <div class="col-md-6">
        <div class="card h-100 shadow-sm">
            <div class="card-body">
                <h5 class="card-title">
                    <i class="bi bi-graph-up text-info me-2"></i>Statistics
                </h5>
                <p>
                    <strong>App Version:</strong> <%=GetAppVersion()%><br>
                    <strong>Started At:</strong> <%=FormatDateTime(Application("StartTime"), vbShortDate)%><br>
                    <strong>Total Requests:</strong> <span class="badge bg-primary"><%=Application("RequestCount")%></span><br>
                    <strong>Session ID:</strong> <code class="small"><%=Session.SessionID%></code>
                </p>
            </div>
        </div>
    </div>
</div>

<div class="alert alert-info mt-4">
    <i class="bi bi-lightbulb me-2"></i>
    <strong>Quick Start:</strong> 
    Head to the <a href="?controller=product&action=list" class="alert-link">Products</a> section to see the CRUD operations in action!
</div>
