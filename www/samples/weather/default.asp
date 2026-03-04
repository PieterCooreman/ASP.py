<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #include file="includes/util.asp" -->
<%
Response.CodePage = 65001
Response.Charset = "UTF-8"
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Will It Rain On My Walk?</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            height: 100%;
            font-family: 'DM Sans', sans-serif;
            background: #f8f9fa;
            color: #1a1a1a;
        }
        
        .app-container {
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        
        header {
            background: #fff;
            padding: 16px 24px;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .logo {
            font-size: 18px;
            font-weight: 700;
            color: #1a1a1a;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .logo-icon {
            width: 32px;
            height: 32px;
            background: linear-gradient(135deg, #4a90d9, #67b26f);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }
        
        .main-content {
            display: flex;
            flex: 1;
            overflow: hidden;
        }
        
        .sidebar {
            width: 380px;
            background: #fff;
            border-right: 1px solid #e9ecef;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }
        
        .route-form {
            padding: 24px;
            border-bottom: 1px solid #e9ecef;
        }
        
        .form-group {
            margin-bottom: 16px;
        }
        
        .form-group label {
            display: block;
            font-size: 12px;
            font-weight: 500;
            color: #6c757d;
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            font-size: 15px;
            font-family: inherit;
            transition: border-color 0.2s;
            background: #fff;
        }
        
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #4a90d9;
        }
        
        .form-row {
            display: flex;
            gap: 12px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .submit-btn {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #4a90d9, #67b26f);
            border: none;
            border-radius: 10px;
            color: #fff;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(74, 144, 217, 0.4);
        }
        
        .submit-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }
        
        .results {
            flex: 1;
            overflow-y: auto;
        }
        
        .verdict {
            padding: 20px 24px;
            background: linear-gradient(135deg, #f8f9fa, #fff);
            border-bottom: 1px solid #e9ecef;
        }
        
        .verdict-label {
            font-size: 11px;
            font-weight: 500;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }
        
        .verdict-text {
            font-size: 17px;
            font-weight: 500;
            line-height: 1.5;
            color: #1a1a1a;
        }
        
        .route-info {
            padding: 16px 24px;
            display: flex;
            gap: 20px;
            border-bottom: 1px solid #e9ecef;
            background: #fafbfc;
        }
        
        .route-stat {
            text-align: center;
        }
        
        .route-stat .value {
            font-size: 20px;
            font-weight: 700;
            color: #1a1a1a;
        }
        
        .route-stat .label {
            font-size: 11px;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .alternatives {
            padding: 20px 24px;
            border-bottom: 1px solid #e9ecef;
        }
        
        .alternatives h3 {
            font-size: 12px;
            font-weight: 500;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        
        .alt-option {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            margin-bottom: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .alt-option:hover {
            border-color: #4a90d9;
            background: #f8f9ff;
        }
        
        .alt-option.dry {
            border-color: #67b26f;
            background: #f0fff4;
        }
        
        .alt-option.rain {
            border-color: #f5a623;
            background: #fffbf0;
        }
        
        .alt-time {
            font-size: 14px;
            font-weight: 600;
            color: #1a1a1a;
            min-width: 60px;
        }
        
        .alt-verdict {
            flex: 1;
            font-size: 13px;
            color: #495057;
        }
        
        .alt-icon {
            font-size: 20px;
        }
        
        .legend {
            padding: 20px 24px;
        }
        
        .legend h3 {
            font-size: 12px;
            font-weight: 500;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        
        .legend-items {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: #495057;
        }
        
        .legend-color {
            width: 16px;
            height: 16px;
            border-radius: 4px;
        }
        
        .legend-color.dry { background: #67b26f; }
        .legend-color.drizzle { background: #f5a623; }
        .legend-color.moderate { background: #e67e22; }
        .legend-color.heavy { background: #e74c3c; }
        
        .map-container {
            flex: 1;
            position: relative;
        }
        
        #map {
            height: 100%;
            width: 100%;
        }
        
        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255,255,255,0.9);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s;
        }
        
        .loading-overlay.visible {
            opacity: 1;
            pointer-events: all;
        }
        
        .loading-spinner {
            text-align: center;
        }
        
        .loading-spinner .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid #e9ecef;
            border-top-color: #4a90d9;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 12px;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        .loading-text {
            font-size: 14px;
            color: #6c757d;
        }
        
        .empty-state {
            padding: 40px 24px;
            text-align: center;
            color: #6c757d;
        }
        
        .empty-state .icon {
            font-size: 48px;
            margin-bottom: 16px;
        }
        
        .empty-state p {
            font-size: 14px;
            line-height: 1.5;
        }
        
        .share-btn {
            background: none;
            border: none;
            padding: 8px 12px;
            font-size: 12px;
            color: #6c757d;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 4px;
            border-radius: 6px;
            transition: background 0.2s;
        }
        
        .share-btn:hover {
            background: #f8f9fa;
            color: #1a1a1a;
        }
        
        @media (max-width: 900px) {
            .main-content {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                max-height: 50%;
            }
            
            .map-container {
                min-height: 300px;
            }
        }
    </style>
</head>
<body>
    <div class="app-container">
        <header>
            <div class="logo">
                <div class="logo-icon">🌦️</div>
                <span>Will It Rain On My Walk?</span>
            </div>
            <button class="share-btn" id="shareBtn" style="display:none;">
                🔗 Share
            </button>
        </header>
        
        <div class="main-content">
            <div class="sidebar">
                <div class="route-form">
                    <div class="form-group">
                        <label>From</label>
                        <input type="text" id="origin" placeholder="Enter starting point..." value="Times Square, New York">
                    </div>
                    
                    <div class="form-group">
                        <label>To</label>
                        <input type="text" id="destination" placeholder="Enter destination..." value="Central Park, New York">
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Departure</label>
                            <select id="departureTime">
                                <option value="now">Leave now</option>
                                <option value="10">In 10 minutes</option>
                                <option value="20">In 20 minutes</option>
                                <option value="30">In 30 minutes</option>
                                <option value="60">In 1 hour</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Walking speed</label>
                            <select id="speed">
                                <option value="slow">Slow</option>
                                <option value="normal" selected>Normal</option>
                                <option value="fast">Fast</option>
                            </select>
                        </div>
                    </div>
                    
                    <button class="submit-btn" id="checkBtn">Check my walk</button>
                </div>
                
                <div class="results" id="results">
                    <div class="empty-state">
                        <div class="icon">🚶</div>
                        <p>Enter your route and click<br>"Check my walk" to see if you'll stay dry.</p>
                    </div>
                </div>
            </div>
            
            <div class="map-container">
                <div id="map"></div>
                <div class="loading-overlay" id="loading">
                    <div class="loading-spinner">
                        <div class="spinner"></div>
                        <div class="loading-text">Checking the weather...</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        const map = L.map('map', {
            zoomControl: false
        }).setView([40.7580, -73.9855], 13);
        
        L.control.zoom({ position: 'bottomright' }).addTo(map);
        
        L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>',
            maxZoom: 19
        }).addTo(map);
        
        let routeLine = null;
        let markers = [];
        let forecastData = null;
        
        const originInput = document.getElementById('origin');
        const destinationInput = document.getElementById('destination');
        const departureSelect = document.getElementById('departureTime');
        const speedSelect = document.getElementById('speed');
        const checkBtn = document.getElementById('checkBtn');
        const resultsDiv = document.getElementById('results');
        const loadingDiv = document.getElementById('loading');
        const shareBtn = document.getElementById('shareBtn');
        
        checkBtn.addEventListener('click', async () => {
            const origin = originInput.value.trim();
            const destination = destinationInput.value.trim();
            const departureTime = departureSelect.value;
            const speed = speedSelect.value;
            
            if (!origin || !destination) {
                alert('Please enter both origin and destination');
                return;
            }
            
            loadingDiv.classList.add('visible');
            
            try {
                const formData = new FormData();
                formData.append('origin', origin);
                formData.append('destination', destination);
                formData.append('departure_time', departureTime);
                formData.append('speed', speed);
                
                const response = await fetch('api/forecast.asp', {
                    method: 'POST',
                    body: formData
                });
                
                if (!response.ok) {
                    throw new Error('Failed to get forecast');
                }
                
                forecastData = await response.json();
                displayResults(forecastData);
                displayRoute(forecastData);
                shareBtn.style.display = 'flex';
                
            } catch (err) {
                console.error('Error:', err);
                alert('Failed to check weather. Please try again.');
            } finally {
                loadingDiv.classList.remove('visible');
            }
        });
        
        function displayResults(data) {
            const duration = data.duration;
            const distance = data.distance;
            
            let alternativesHtml = '<div class="alternatives"><h3>Leave now vs. wait</h3>';
            
            alternativesHtml += `<div class="alt-option ${data.has_rain ? 'rain' : 'dry'}">
                <span class="alt-time">Now</span>
                <span class="alt-verdict">${data.verdict}</span>
                <span class="alt-icon">${data.has_rain ? '🌧️' : '☀️'}</span>
            </div>`;
            
            data.alternatives.forEach(alt => {
                if (alt.wait_minutes > 0) {
                    const waitText = alt.wait_minutes >= 60 ? '1 hour' : alt.wait_minutes + ' min';
                    alternativesHtml += `<div class="alt-option ${alt.has_rain ? 'rain' : 'dry'}">
                        <span class="alt-time">+${waitText}</span>
                        <span class="alt-verdict">${alt.verdict}</span>
                        <span class="alt-icon">${alt.has_rain ? '🌧️' : '☀️'}</span>
                    </div>`;
                }
            });
            
            alternativesHtml += '</div>';
            
            resultsDiv.innerHTML = `
                <div class="verdict">
                    <div class="verdict-label">The verdict</div>
                    <div class="verdict-text">${data.verdict}</div>
                </div>
                
                <div class="route-info">
                    <div class="route-stat">
                        <div class="value">${Math.round(distance)}</div>
                        <div class="label">km</div>
                    </div>
                    <div class="route-stat">
                        <div class="value">${duration}</div>
                        <div class="label">min</div>
                    </div>
                    <div class="route-stat">
                        <div class="value">${data.speed}</div>
                        <div class="label">pace</div>
                    </div>
                </div>
                
                ${alternativesHtml}
                
                <div class="legend">
                    <h3>Route legend</h3>
                    <div class="legend-items">
                        <div class="legend-item">
                            <div class="legend-color dry"></div>
                            <span>Dry</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color drizzle"></div>
                            <span>Light drizzle</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color moderate"></div>
                            <span>Moderate rain</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-color heavy"></div>
                            <span>Heavy rain</span>
                        </div>
                    </div>
                </div>
            `;
            
            document.querySelectorAll('.alt-option').forEach((option, index) => {
                option.addEventListener('click', () => {
                    departureSelect.value = index === 0 ? 'now' : (index * 10).toString();
                    checkBtn.click();
                });
            });
        }
        
        function displayRoute(data) {
            markers.forEach(m => map.removeLayer(m));
            markers = [];
            
            if (routeLine) {
                map.removeLayer(routeLine);
            }
            
            const originIcon = L.divIcon({
                html: '<div style="width:24px;height:24px;background:#4a90d9;border-radius:50%;border:3px solid #fff;box-shadow:0 2px 8px rgba(0,0,0,0.3)"></div>',
                className: 'marker-icon',
                iconSize: [24, 24],
                iconAnchor: [12, 12]
            });
            
            const destIcon = L.divIcon({
                html: '<div style="width:24px;height:24px;background:#e74c3c;border-radius:50%;border:3px solid #fff;box-shadow:0 2px 8px rgba(0,0,0,0.3)"></div>',
                className: 'marker-icon',
                iconSize: [24, 24],
                iconAnchor: [12, 12]
            });
            
            const originMarker = L.marker([data.origin.lat, data.origin.lng], { icon: originIcon }).addTo(map);
            originMarker.bindPopup(`<b>From:</b> ${data.origin.name}`);
            
            const destMarker = L.marker([data.destination.lat, data.destination.lng], { icon: destIcon }).addTo(map);
            destMarker.bindPopup(`<b>To:</b> ${data.destination.name}`);
            
            markers.push(originMarker, destMarker);
            
            const latlngs = [
                [data.origin.lat, data.origin.lng],
                [data.destination.lat, data.destination.lng]
            ];
            
            const routeCoords = data.waypoints.map(wp => [wp.lat, wp.lng]);
            
            routeCoords.forEach((coord, i) => {
                const wp = data.waypoints[i];
                const color = getColorForIntensity(wp.intensity);
                
                if (i < routeCoords.length - 1) {
                    const segment = L.polyline([coord, routeCoords[i + 1]], {
                        color: color,
                        weight: 6,
                        opacity: 0.8
                    }).addTo(map);
                    
                    if (wp.intensity !== 'dry') {
                        segment.bindPopup(`${wp.intensity} at minute ${i + 1}<br>Precipitation: ${wp.precipitation} mm/h`);
                    }
                }
            });
            
            map.fitBounds(L.latLngBounds(routeCoords), { padding: [50, 50] });
        }
        
        function getColorForIntensity(intensity) {
            switch (intensity) {
                case 'dry': return '#67b26f';
                case 'drizzle': return '#f5a623';
                case 'moderate': return '#e67e22';
                case 'heavy': return '#e74c3c';
                default: return '#67b26f';
            }
        }
        
        shareBtn.addEventListener('click', () => {
            const params = new URLSearchParams({
                o: originInput.value,
                d: destinationInput.value,
                t: departureSelect.value,
                s: speedSelect.value
            });
            
            const url = `${window.location.origin}${window.location.pathname}?${params}`;
            navigator.clipboard.writeText(url).then(() => {
                alert('Share link copied to clipboard!');
            });
        });
        
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('o') && urlParams.has('d')) {
            originInput.value = urlParams.get('o');
            destinationInput.value = urlParams.get('d');
            departureSelect.value = urlParams.get('t') || 'now';
            speedSelect.value = urlParams.get('s') || 'normal';
            checkBtn.click();
        }
    </script>
</body>
</html>
