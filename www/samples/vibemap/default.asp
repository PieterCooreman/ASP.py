<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #include file="includes/includes.asp" -->
<%
Response.CodePage = 65001
Response.Charset = "UTF-8"
Dim db, pinSvc, activeCount
Set db = New cls_db
db.Open
Set pinSvc = New cls_pin
pinSvc.CleanupExpired db
activeCount = pinSvc.GetPinCount(db)
db.Close
Set db = Nothing
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vibe Map — Drop Your Vibe</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            height: 100%;
            width: 100%;
            overflow: hidden;
            font-family: 'Outfit', sans-serif;
        }
        
        #map {
            height: 100%;
            width: 100%;
            z-index: 1;
        }
        
        .vibe-counter {
            position: fixed;
            top: 20px;
            right: 20px;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(12px);
            color: #1a1a1a;
            padding: 12px 20px;
            border-radius: 50px;
            font-size: 14px;
            font-weight: 400;
            z-index: 1000;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            border: 1px solid rgba(0,0,0,0.1);
        }
        
        .vibe-counter .pulse {
            width: 8px;
            height: 8px;
            background: #00A854;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(1.2); }
            100% { opacity: 1; transform: scale(1); }
        }
        
        .vibe-picker {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(16px);
            padding: 20px 24px;
            border-radius: 20px;
            z-index: 1000;
            display: none;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            border: 1px solid rgba(0,0,0,0.1);
            max-width: 90vw;
        }
        
        .vibe-picker.visible {
            display: block;
            animation: slideUp 0.3s ease-out;
        }
        
        @keyframes slideUp {
            from { opacity: 0; transform: translateX(-50%) translateY(20px); }
            to { opacity: 1; transform: translateX(-50%) translateY(0); }
        }
        
        .vibe-picker h3 {
            color: #1a1a1a;
            font-size: 14px;
            font-weight: 400;
            margin-bottom: 16px;
            text-align: center;
            opacity: 0.8;
        }
        
        .vibe-option {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 10px 6px;
            background: rgba(0,0,0,0.04);
            border: 2px solid transparent;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .vibe-option:hover {
            background: rgba(0,0,0,0.08);
            transform: translateY(-2px);
        }
        
        .vibe-option.selected {
            border-color: #00A854;
            background: rgba(0, 168, 84, 0.1);
        }
        
        .vibe-option .emoji {
            font-size: 24px;
            margin-bottom: 4px;
        }
        
        .vibe-option .label {
            font-size: 9px;
            color: rgba(0,0,0,0.6);
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 60px;
        }
        
        .vibe-input {
            width: 100%;
            padding: 12px 16px;
            background: rgba(0,0,0,0.04);
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 10px;
            color: #1a1a1a;
            font-size: 14px;
            font-family: 'Outfit', sans-serif;
            margin-bottom: 16px;
            outline: none;
            transition: border-color 0.2s;
        }
        
        .vibe-input:focus {
            border-color: rgba(0, 168, 84, 0.5);
        }
        
        .vibe-input::placeholder {
            color: rgba(0,0,0,0.4);
        }
        
        .vibe-actions {
            display: flex;
            gap: 10px;
        }
        
        .vibe-btn {
            flex: 1;
            padding: 12px 20px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            font-family: 'Outfit', sans-serif;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .vibe-btn.primary {
            background: linear-gradient(135deg, #00A854, #007A3D);
            color: #fff;
        }
        
        .vibe-btn.primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0, 168, 84, 0.4);
        }
        
        .vibe-btn.secondary {
            background: rgba(0,0,0,0.06);
            color: rgba(0,0,0,0.7);
        }
        
        .vibe-btn.secondary:hover {
            background: rgba(0,0,0,0.1);
        }
        
        .leaflet-popup-content-wrapper {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px);
            border-radius: 14px;
            border: 1px solid rgba(0,0,0,0.1);
            box-shadow: 0 8px 32px rgba(0,0,0,0.15);
        }
        
        .leaflet-popup-content {
            color: #1a1a1a;
            font-family: 'Outfit', sans-serif;
            margin: 14px 16px;
        }
        
        .leaflet-popup-tip {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid rgba(0,0,0,0.1);
        }
        
        .leaflet-popup-close-button {
            color: rgba(0,0,0,0.5) !important;
        }
        
        .leaflet-popup-close-button:hover {
            color: #000 !important;
        }
        
        .pin-popup {
            text-align: center;
        }
        
        .pin-popup .emoji {
            font-size: 36px;
            display: block;
            margin-bottom: 6px;
        }
        
        .pin-popup .label {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 6px;
        }
        
        .pin-popup .message {
            font-size: 13px;
            color: rgba(0,0,0,0.6);
            margin-bottom: 8px;
            font-style: italic;
        }
        
        .pin-popup .time {
            font-size: 11px;
            color: rgba(0,0,0,0.4);
        }
        
        .pin-popup .report-btn {
            display: block;
            margin-top: 10px;
            padding: 6px 12px;
            background: rgba(0,0,0,0.05);
            border: none;
            border-radius: 6px;
            color: rgba(0,0,0,0.5);
            font-size: 11px;
            cursor: pointer;
            font-family: 'Outfit', sans-serif;
            transition: all 0.2s;
        }
        
        .pin-popup .report-btn:hover {
            background: rgba(255,60,60,0.15);
            color: #e53935;
        }
        
        .vibe-marker {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 44px;
            height: 44px;
            font-size: 28px;
            background: rgba(30, 30, 35, 0.9);
            border-radius: 50%;
            box-shadow: 0 4px 15px rgba(0,0,0,0.4);
            border: 2px solid rgba(255,255,255,0.2);
            transition: all 0.3s ease;
            animation: float 3s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-4px); }
        }
        
        .vibe-marker.new {
            animation: dropIn 0.5s ease-out, float 3s ease-in-out infinite 0.5s;
        }
        
        @keyframes dropIn {
            0% { transform: scale(0) translateY(-30px); opacity: 0; }
            60% { transform: scale(1.1) translateY(0); }
            100% { transform: scale(1) translateY(0); opacity: 1; }
        }
        
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: #f5f7fb;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            transition: opacity 0.5s ease;
        }
        
        .loading-overlay.hidden {
            opacity: 0;
            pointer-events: none;
        }
        
        .loading-text {
            color: rgba(0,0,0,0.5);
            font-size: 14px;
            letter-spacing: 2px;
        }
        
        @media (max-width: 600px) {
            .vibe-grid {
                grid-template-columns: repeat(4, 1fr);
            }
            
            .vibe-option {
                padding: 8px 4px;
            }
            
            .vibe-option .emoji {
                font-size: 20px;
            }
            
            .vibe-option .label {
                font-size: 8px;
                max-width: 50px;
            }
        }
    </style>
</head>
<body>
    <div class="loading-overlay" id="loading">
        <div class="loading-text">LOADING VIBES...</div>
    </div>
    
    <div class="vibe-counter" id="counter">
        <span class="pulse"></span>
        <span><span id="activeCount"><%=activeCount%></span> vibes active right now</span>
    </div>
    
    <div id="map"></div>
    
    <div class="vibe-picker" id="picker">
        <h3>How are you feeling?</h3>
        <div class="vibe-grid" id="vibeGrid"></div>
        <input type="text" class="vibe-input" id="vibeMessage" placeholder="Add a short message (optional)..." maxlength="80">
        <div class="vibe-actions">
            <button class="vibe-btn secondary" id="cancelBtn">Cancel</button>
            <button class="vibe-btn primary" id="dropBtn">Drop Vibe</button>
        </div>
    </div>
    
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        const vibes = [
            { emoji: '🔥', label: 'On fire' },
            { emoji: '😴', label: 'Sleepy' },
            { emoji: '🎵', label: 'Vibing to music' },
            { emoji: '💼', label: 'Working' },
            { emoji: '🍕', label: 'Eating' },
            { emoji: '✨', label: 'Inspired' },
            { emoji: '🧘', label: 'Chill' },
            { emoji: '🥳', label: 'Celebrating' },
            { emoji: '😤', label: 'Frustrated' },
            { emoji: '💭', label: 'Deep thinking' },
            { emoji: '😄', label: 'Happy' },
            { emoji: '😢', label: 'Sad' }
        ];
        
        const map = L.map('map', {
            zoomControl: false
        }).setView([20, 0], 2);
        
        L.control.zoom({ position: 'bottomright' }).addTo(map);
        
        L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a> &copy; <a href="https://carto.com/">CARTO</a>',
            maxZoom: 19
        }).addTo(map);
        
        const markers = {};
        let selectedVibe = null;
        let pendingLat = null;
        let pendingLng = null;
        
        const vibeGrid = document.getElementById('vibeGrid');
        vibes.forEach((vibe, index) => {
            const option = document.createElement('div');
            option.className = 'vibe-option';
            option.dataset.emoji = vibe.emoji;
            option.dataset.label = vibe.label;
            option.innerHTML = `
                <span class="emoji">${vibe.emoji}</span>
                <span class="label">${vibe.label}</span>
            `;
            option.addEventListener('click', () => {
                document.querySelectorAll('.vibe-option').forEach(o => o.classList.remove('selected'));
                option.classList.add('selected');
                selectedVibe = vibe;
            });
            vibeGrid.appendChild(option);
        });
        
        const picker = document.getElementById('picker');
        const messageInput = document.getElementById('vibeMessage');
        
        map.on('click', (e) => {
            pendingLat = e.latlng.lat;
            pendingLng = e.latlng.lng;
            picker.classList.add('visible');
            messageInput.value = '';
            selectedVibe = null;
            document.querySelectorAll('.vibe-option').forEach(o => o.classList.remove('selected'));
            messageInput.focus();
        });
        
        document.getElementById('cancelBtn').addEventListener('click', () => {
            picker.classList.remove('visible');
            selectedVibe = null;
            pendingLat = null;
            pendingLng = null;
        });
        
        document.getElementById('dropBtn').addEventListener('click', async () => {
            if (!selectedVibe || !pendingLat || !pendingLng) return;
            
            const message = messageInput.value.trim();
            
            try {
                const formData = new FormData();
                formData.append('emoji', selectedVibe.emoji);
                formData.append('label', selectedVibe.label);
                formData.append('message', message);
                formData.append('lat', pendingLat);
                formData.append('lng', pendingLng);
                
                const response = await fetch('api/pins.asp', {
                    method: 'POST',
                    body: formData
                });
                
                const data = await response.json();
                
                if (data.error) {
                    alert(data.error);
                    return;
                }
                
                addMarker({
                    id: data.id,
                    emoji: selectedVibe.emoji,
                    label: selectedVibe.label,
                    message: message,
                    lat: pendingLat,
                    lng: pendingLng,
                    color: getVibeColor(selectedVibe.emoji),
                    created_at: new Date().toISOString(),
                    reports: 0
                }, true);
                
                picker.classList.remove('visible');
                selectedVibe = null;
                pendingLat = null;
                pendingLng = null;
                updateCount();
                
            } catch (err) {
                console.error('Failed to drop vibe:', err);
                alert('Failed to drop vibe. Please try again.');
            }
        });
        
        function getVibeColor(emoji) {
            const colors = {
                '🔥': '#FF6B35',
                '😴': '#6B5B95',
                '🎵': '#88B04B',
                '💼': '#45B8AC',
                '🍕': '#EFC050',
                '✨': '#DD4124',
                '🧘': '#5B5EA6',
                '🥳': '#FF69B4',
                '😤': '#E15D44',
                '💭': '#9B2335',
                '😄': '#00A86B',
                '😢': '#6495ED'
            };
            return colors[emoji] || '#888888';
        }
        
        function fuzzyTime(dateStr) {
            const date = new Date(dateStr.replace(' ', 'T'));
            const now = new Date();
            const diff = Math.floor((now - date) / 1000 / 60);
            
            if (diff < 1) return 'just now';
            if (diff < 60) return `${diff} min ago`;
            if (diff < 1440) return `${Math.floor(diff / 60)} hr ago`;
            return `${Math.floor(diff / 1440)} days ago`;
        }
        
        function addMarker(pin, isNew = false) {
            if (markers[pin.id]) {
                map.removeLayer(markers[pin.id]);
            }
            
            const el = document.createElement('div');
            el.className = `vibe-marker ${isNew ? 'new' : ''}`;
            el.textContent = pin.emoji;
            el.style.borderColor = pin.color;
            
            const icon = L.divIcon({
                html: el.outerHTML,
                className: 'vibe-icon',
                iconSize: [44, 44],
                iconAnchor: [22, 22]
            });
            
            const marker = L.marker([pin.lat, pin.lng], { icon }).addTo(map);
            
            const popupContent = `
                <div class="pin-popup">
                    <span class="emoji">${pin.emoji}</span>
                    <div class="label">${pin.label}</div>
                    ${pin.message ? `<div class="message">"${pin.message}"</div>` : ''}
                    <div class="time">${fuzzyTime(pin.created_at)}</div>
                    <button class="report-btn" data-id="${pin.id}">Report</button>
                </div>
            `;
            
            marker.bindPopup(popupContent, { maxWidth: 250 });
            
            marker.on('popupopen', () => {
                document.querySelectorAll('.report-btn').forEach(btn => {
                    btn.addEventListener('click', async (e) => {
                        e.stopPropagation();
                        const pinId = btn.dataset.id;
                        if (confirm('Report this vibe as inappropriate?')) {
                            try {
                                await fetch(`api/report.asp?id=${pinId}`, { method: 'POST' });
                                alert('Report submitted. Thank you!');
                                map.closePopup();
                            } catch (err) {
                                console.error('Report failed:', err);
                            }
                        }
                    });
                });
            });
            
            markers[pin.id] = marker;
        }
        
        async function loadPins() {
            try {
                const response = await fetch('api/pins.asp');
                const pins = await response.json();
                
                pins.forEach(pin => addMarker(pin));
                
                document.getElementById('activeCount').textContent = pins.length;
                document.getElementById('loading').classList.add('hidden');
                
            } catch (err) {
                console.error('Failed to load pins:', err);
                document.getElementById('loading').classList.add('hidden');
            }
        }
        
        async function updateCount() {
            try {
                const response = await fetch('api/pins.asp');
                const pins = await response.json();
                document.getElementById('activeCount').textContent = pins.length;
            } catch (err) {
                console.error('Failed to update count:', err);
            }
        }
        
        loadPins();
        
        setInterval(async () => {
            const existingIds = Object.keys(markers);
            try {
                const response = await fetch('api/pins.asp');
                const pins = await response.json();
                
                const currentIds = pins.map(p => p.id);
                
                existingIds.forEach(id => {
                    if (!currentIds.includes(id)) {
                        if (markers[id]) {
                            map.removeLayer(markers[id]);
                            delete markers[id];
                        }
                    }
                });
                
                pins.forEach(pin => {
                    if (!markers[pin.id]) {
                        addMarker(pin, true);
                    }
                });
                
                document.getElementById('activeCount').textContent = pins.length;
                
            } catch (err) {
                console.error('Failed to refresh:', err);
            }
        }, 10000);
    </script>
</body>
</html>
