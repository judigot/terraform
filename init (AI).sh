#!/bin/bash

main() {
    waitForAptLock
    fixDockerPermissions
    installOllama
    startOllama
    pullDeepSeek
    configureNginxProxy
    runOpenWebUI
    showEndpoints
}

waitForAptLock() {
    echo "⏳ Waiting for apt/dpkg lock to be released..."
    while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
        sleep 5
    done
}

fixDockerPermissions() {
    echo "[1/6] Adding user to Docker group..."
    sudo usermod -aG docker $USER
}

installOllama() {
    echo "[2/6] Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
}

startOllama() {
    echo "[3/6] Starting Ollama..."
    nohup ollama serve > /dev/null 2>&1 &
    sleep 5
}

pullDeepSeek() {
    echo "[4/6] Pulling DeepSeek Coder 6.7B..."
    ollama pull deepseek-coder:6.7b
}

configureNginxProxy() {
    echo "[5/6] Configuring NGINX as CORS proxy for Ollama..."
    sudo tee /etc/nginx/sites-available/ollama_proxy > /dev/null <<EOF
server {
    listen 8080;

    location / {
        proxy_pass http://localhost:11434;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # CORS Headers
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
        add_header Access-Control-Allow-Headers 'Content-Type, Authorization';

        if (\$request_method = OPTIONS) {
            add_header Content-Length 0;
            add_header Content-Type text/plain;
            return 204;
        }
    }
}
EOF

    sudo ln -s /etc/nginx/sites-available/ollama_proxy /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo systemctl restart nginx
}

runOpenWebUI() {
    echo "[6/6] Running OpenWebUI with Docker..."
    sudo docker run -d \
        --restart unless-stopped \
        -p 3000:3000 \
        -v openwebui-data:/app/backend/data \
        -e OLLAMA_BASE_URL=http://localhost:11434 \
        --name openwebui \
        ghcr.io/open-webui/open-webui:main
}

showEndpoints() {
    echo ""
    echo "✅ SETUP COMPLETE — ENDPOINTS:"
    echo "🌐 Web Chat Interface: http://<your-ec2-ip>:3000"
    echo "📡 CORS-Ready API:     http://<your-ec2-ip>:8080/api/generate"
    echo ""
    echo "Use this endpoint in your React app:"
    echo "fetch('http://<your-ec2-ip>:8080/api/generate', { method: 'POST', ... })"
}

main
