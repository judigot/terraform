#!/bin/bash

main() {
    # removeOllama
    fixDockerPermissions
    stopSystemdOllama
    installOllama
    configureOllamaService
    startOllama
    pullDeepSeek
    runOpenWebUI
    showEndpoints
    install_certbot_and_ssl example.com example@example.com
    configureNginxProxy

    # ==============================
    # sudo lsof -i :11434

    # sudo pkill -f "ollama serve"

    # sudo systemctl daemon-reload && sudo systemctl enable ollama && sudo systemctl start ollama

    # docker exec openwebui printenv | grep OLLAMA

    # vim /etc/systemd/system/ollama.service

    # ExecStart=/usr/bin/env OLLAMA_HOST=0.0.0.0 /usr/local/bin/ollama serve

    # ExecStart=/usr/bin/ollama serve
}

fixDockerPermissions() {
    echo "Adding user to Docker group..."
    sudo usermod -aG docker "$USER"
}

installOllama() {
    echo "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
}

configureOllamaService() {
    echo "Configuring Ollama systemd service..."
    
    # Check if the service file exists
    if [ -f /etc/systemd/system/ollama.service ]; then
        # Backup the original service file
        sudo cp /etc/systemd/system/ollama.service /etc/systemd/system/ollama.service.backup
        
        # Replace the ExecStart line to include OLLAMA_HOST=0.0.0.0
        sudo sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/env OLLAMA_HOST=0.0.0.0 /usr/local/bin/ollama serve|' /etc/systemd/system/ollama.service
        
        # Reload systemd to pick up the changes
        sudo systemctl daemon-reload
        
        echo "✅ Updated Ollama service to bind to 0.0.0.0"
    else
        echo "⚠️  Ollama systemd service file not found, will use environment variable instead"
    fi
}

stopSystemdOllama() {
    echo "Stopping systemd-based Ollama service (if exists)..."
    if systemctl is-active --quiet ollama; then
        sudo systemctl stop ollama
        sudo systemctl disable ollama
        sudo systemctl daemon-reload
        echo "🛑 Stopped systemd Ollama service."
    fi
}

startOllama() {
    echo "Starting Ollama on 0.0.0.0..."

    export OLLAMA_HOST=0.0.0.0

    # Ensure no duplicate Ollama processes
    sudo pkill -f "ollama serve" 2>/dev/null || true

    # Start Ollama in the background
    sudo nohup ollama serve >/var/log/ollama.log 2>&1 &

    sleep 5
}

pullDeepSeek() {
    echo "Pulling DeepSeek R1 Latest..."
    
    # Wait for Ollama to be ready
    echo "⏳ Waiting for Ollama server to be ready..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if ollama list >/dev/null 2>&1; then
            echo "✅ Ollama server is ready!"
            break
        fi
        
        attempt=$((attempt + 1))
        echo "   Attempt $attempt/$max_attempts - waiting 2 seconds..."
        sleep 2
    done
    
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ Error: Ollama server failed to start after $max_attempts attempts"
        echo "   Check the logs: tail -f /var/log/ollama.log"
        return 1
    fi
    
    # Now pull the model
    ollama pull deepseek-r1:1.5b
}

install_certbot_and_ssl() {
    DOMAIN=$1
    EMAIL=$2

    if [[ -z "$DOMAIN" || -z "$EMAIL" ]]; then
        echo "❌ Usage: install_certbot_and_ssl yourdomain.com your@email.com"
        return 1
    fi

    echo "📦 Installing NGINX and Certbot..."
    sudo apt update
    sudo apt install -y nginx python3-certbot-nginx

    echo "🔐 Issuing SSL cert for: $DOMAIN and www.$DOMAIN"
    sudo certbot --nginx -n --agree-tos --email "$EMAIL" --redirect \
        -d "$DOMAIN" -d "www.$DOMAIN"

    echo "🔁 Testing auto-renewal..."
    sudo certbot renew --dry-run

    echo "✅ SSL certificates are now active for: $DOMAIN and www.$DOMAIN"
    echo "📁 Stored in: /etc/letsencrypt/live/$DOMAIN/"
}


configureNginxProxy() {
    echo "Configuring NGINX as CORS proxy for Ollama..."

    sudo tee /etc/nginx/sites-available/ollama_proxy >/dev/null <<EOF
server {
    listen 80;
    server_name judigot.com www.judigot.com;

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name judigot.com www.judigot.com;

    ssl_certificate /etc/letsencrypt/live/judigot.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/judigot.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # -----------------------------------------
    # Ollama API Proxy (DeepSeek Endpoint)
    # -----------------------------------------
    location /api/deepseek {
        proxy_pass http://localhost:11434/api/generate;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_buffering off;

        # CORS headers for preflight and real requests
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS' always;
        add_header Access-Control-Allow-Headers 'Content-Type, Authorization' always;

        if (\$request_method = OPTIONS) {
            add_header Content-Length 0;
            add_header Content-Type text/plain;
            return 204;
        }
    }

    # -----------------------------------------
    # OpenWebUI Reverse Proxy (Default path /)
    # -----------------------------------------
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # WebSocket support for OpenWebUI
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
EOF

    sudo ln -sf /etc/nginx/sites-available/ollama_proxy /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default

    # Test nginx configuration
    echo "🔍 Testing NGINX configuration..."
    if sudo nginx -t; then
        echo "✅ NGINX configuration is valid"
        
        # Ensure nginx is running
        sudo systemctl enable nginx
        sudo systemctl reload nginx
        
        # Check if nginx is running
        if systemctl is-active --quiet nginx; then
            echo "✅ NGINX is running"
        else
            echo "🔄 Starting NGINX..."
            sudo systemctl start nginx
        fi
        
        # Show debugging information
        echo ""
        echo "🔍 NGINX Debug Information:"
        echo "   NGINX Status: $(systemctl is-active nginx)"
        echo "   Port 80 listening: $(sudo netstat -tlnp | grep ':80 ' || echo 'Not listening')"
        echo "   Port 443 listening: $(sudo netstat -tlnp | grep ':443 ' || echo 'Not listening')"
        echo "   OpenWebUI Status: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000 || echo 'Connection failed')"
        
        echo ""
        echo "📝 Troubleshooting tips:"
        echo "   1. Check NGINX error logs: sudo tail -f /var/log/nginx/error.log"
        echo "   2. Check if SSL certificates exist: ls -la /etc/letsencrypt/live/judigot.com/"
        echo "   3. Test OpenWebUI directly: curl -I http://localhost:3000"
        echo "   4. Check firewall: sudo ufw status"
        
    else
        echo "❌ NGINX configuration test failed!"
        echo "   Check the configuration manually: sudo nginx -t"
        return 1
    fi
}

runOpenWebUI() {
    echo "Running OpenWebUI with Docker..."

    # Automatically detect host IP
    IP=$(hostname -I | awk '{print $1}')
    echo "🌐 Using host IP: $IP for OLLAMA_BASE_URL"

    # Remove container, image, and volumes
    sudo docker rm -f openwebui 2>/dev/null || true
    sudo docker volume rm openwebui-data 2>/dev/null || true
    sudo docker rmi ghcr.io/open-webui/open-webui:main 2>/dev/null || true

    sudo docker run -d \
        --restart unless-stopped \
        -p 3000:3000 \
        -v openwebui-data:/app/backend/data \
        -e OLLAMA_BASE_URL=http://$IP:11434 \
        -e WEBUI_HOST=0.0.0.0 \
        -e WEBUI_AUTH=true \
        -e WEBUI_SECRET_KEY=mySuperSecretKey123 \
        --name openwebui \
        ghcr.io/open-webui/open-webui:main \
        uvicorn open_webui.main:app --host 0.0.0.0 --port 3000
}

showEndpoints() {
    echo ""
    echo "✅ SETUP COMPLETE — ENDPOINTS:"
    echo "🌐 Web Chat Interface: http://yourEC2ipaddress:3000"
    echo "📡 CORS-Ready API:     http://yourEC2ipaddress:8080/api/generate"
    echo ""
    echo "Use this endpoint in your React app:"
    echo "fetch('http://<your-ec2-ip>:8080/api/generate', { method: 'POST', ... })"
    echo ""
    echo "📓 Logs: tail -f ollama.log"
}

removeOllama() {
    echo "Removing Ollama..."
    sudo rm /etc/systemd/system/ollama.service
    sudo pkill -f "ollama serve" 2>/dev/null || true

    sudo apt-get purge ollama

    # Clean up unused dependencies
    sudo apt-get autoremove

    # Remove any remaining Ollama-related files (configuration, data, logs)
    sudo rm -rf /etc/ollama
    sudo rm -rf /var/lib/ollama
    sudo rm -rf /var/log/ollama

    # Remove any residual Ollama binaries or files from /usr/local/bin or /usr/bin if necessary
    sudo rm -f /usr/local/bin/ollama
    sudo rm -f /usr/bin/ollama

    # Remove any possible Ollama-related directories in user home (e.g., hidden config files)
    sudo rm -rf ~/.ollama

    # Remove Ollama's dependencies if no longer needed
    sudo apt-get autoremove --purge

    # Verify no Ollama-related processes are running
    ps aux | grep ollama

    # Verify if the Ollama package has been completely removed
    dpkg -l | grep ollama
}

main
