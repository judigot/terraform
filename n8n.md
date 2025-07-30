google sheets
ec2 instance
n8n dns setup
docker-compose.yml
    admin
    n8n@123

sudo vim /etc/nginx/sites-available/n8n
server {
    listen 80;
    server_name n8n.judigot.com;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

Enable the config:
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

Assign SSL to n8n.judigot.com
Create n8n account

Create Credential in n8n:
    Google Sheets OAuth2 API
    Copy the OAuth Redirect URL from n8n
    Keep the n8n tab open

Setup a google cloud project
    APIs & Services
    OAuth consent screen
        External
        App name: n8n
        User support email: judigot@gmail.com
    Create OAuth client ID
        Application type: Web application
            Under Authorized redirect URIs, click Add URI
            Paste the OAuth Redirect URL from n8n
            Click Create
    Copy the Client ID and Client Secret to n8n
    Sign in to your Google Account to connect
    Enable Google Sheets API
        APIs & Services
        Library
        Search for Google Sheets API
        Enable it
    Enable Google Drive API
        APIs & Services
        Library
        Search for Google Drive API
        Enable it