#!/bin/bash

main() {
    # fixDockerPermissions
    # stopSystemdOllama
    # installOllama
    # startOllama
    # pullDeepSeek
    install_certbot_and_ssl "judigot.com"
    configureNginxProxy
    runOpenWebUI
    showEndpoints

    # docker exec openwebui printenv | grep OLLAMA

    # vim /etc/systemd/system/ollama.service

    # ExecStart=/usr/bin/env OLLAMA_HOST=0.0.0.0 /usr/local/bin/ollama serve
    
    # ExecStart=/usr/bin/ollama serve

    # sudo systemctl daemon-reload
    # sudo systemctl enable ollama
    # sudo systemctl start ollama



    # Remove ollama

    # sudo apt-get purge ollama

    # # Clean up unused dependencies
    # sudo apt-get autoremove

    # # Remove any remaining Ollama-related files (configuration, data, logs)
    # sudo rm -rf /etc/ollama
    # sudo rm -rf /var/lib/ollama
    # sudo rm -rf /var/log/ollama

    # # Remove any residual Ollama binaries or files from /usr/local/bin or /usr/bin if necessary
    # sudo rm -f /usr/local/bin/ollama
    # sudo rm -f /usr/bin/ollama

    # # Remove any possible Ollama-related directories in user home (e.g., hidden config files)
    # sudo rm -rf ~/.ollama

    # # Remove Ollama's dependencies if no longer needed
    # sudo apt-get autoremove --purge

    # # Verify no Ollama-related processes are running
    # ps aux | grep ollama

    # # If any processes are still running, kill them
    # sudo kill <pid>

    # # Verify if the Ollama package has been completely removed
    # dpkg -l | grep ollama
    
}

fixDockerPermissions() {
    echo "[1/8] Adding user to Docker group..."
    sudo usermod -aG docker "$USER"
}

installOllama() {
    echo "[2/8] Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
}

stopSystemdOllama() {
    echo "[3/8] Stopping systemd-based Ollama service (if exists)..."
    if systemctl is-active --quiet ollama; then
        sudo systemctl stop ollama
        sudo systemctl disable ollama
        sudo systemctl daemon-reload
        echo "🛑 Stopped systemd Ollama service."
    fi
}

startOllama() {
    echo "[4/8] Starting Ollama on 0.0.0.0..."

    export OLLAMA_HOST=0.0.0.0

    # Ensure no duplicate Ollama processes
    pkill -f "ollama serve" 2>/dev/null || true

    # Start Ollama in the background
    nohup ollama serve > /var/log/ollama.log 2>&1 &

    sleep 5
}

pullDeepSeek() {
    echo "[5/8] Pulling DeepSeek R1 Latest..."
    ollama pull deepseek-r1:latest
}

install_certbot_and_ssl() {
  DOMAIN=$1

  # Install Certbot and the NGINX plugin
  sudo apt install -y python3-certbot-nginx

  # Generate SSL certificates for the primary domain
  sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN

  # Auto-renew the SSL certificate (Certbot automatically installs a cron job for this)
  sudo certbot renew --dry-run

  # Keys are stored in /etc/letsencrypt
  echo "SSL certificates are located in /etc/letsencrypt/live/$DOMAIN/"
}

configureNginxProxy() {
    echo "[6/8] Configuring NGINX as CORS proxy for Ollama..."

    # Configure the NGINX proxy settings for Ollama and OpenWebUI
    sudo tee /etc/nginx/sites-available/ollama_proxy > /dev/null <<EOF
# /etc/nginx/sites-available/judigot.com
server {
    listen 80;
    server_name judigot.com;

    # Redirect HTTP to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name judigot.com;

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
        proxy_pass http://localhost:3000;  # Assuming OpenWebUI runs on port 3000
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    # Enable the new NGINX site and remove the default site
    sudo ln -sf /etc/nginx/sites-available/ollama_proxy /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default

    # Restart NGINX to apply changes
    sudo systemctl restart nginx
}

runOpenWebUI() {
    echo "[7/8] Running OpenWebUI with Docker..."

    # Automatically detect host IP
    IP=$(hostname -I | awk '{print $1}')
    echo "🌐 Using host IP: $IP for OLLAMA_BASE_URL"

    sudo docker rm -f openwebui 2>/dev/null || true

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

main
