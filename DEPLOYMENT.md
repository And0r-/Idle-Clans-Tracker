# Production Deployment

## Setup auf dem Server

### 1. Repository klonen
```bash
git clone <your-repo-url>
cd Idle-Clans-Tracker
```

### 2. Production Environment konfigurieren
```bash
cp .env.production .env
```

**Bearbeite `.env` und setze:**
- `POSTGRES_PASSWORD`: Sicheres Database-Passwort
- `SECRET_KEY_BASE`: Generiere mit `rails secret`

### 3. Secret Key Base generieren
```bash
# Lokal ausführen oder in temporärem Container:
docker run --rm ruby:3.2-alpine -c "gem install rails && rails secret"
```

### 4. Container bauen und starten
```bash
# Bauen und starten
docker-compose up -d --build

# Database Setup (nur beim ersten Mal)
docker-compose exec app bundle exec rails db:create
docker-compose exec app bundle exec rails db:migrate
docker-compose exec app bundle exec rails db:seed
```

### 5. Logs prüfen
```bash
# App-Logs
docker-compose -f docker-compose.production.yml logs -f app

# Sidekiq-Logs
docker-compose -f docker-compose.production.yml logs -f sidekiq

# Alle Logs
docker-compose -f docker-compose.production.yml logs -f
```

## Reverse Proxy Setup

### Nginx Proxy Manager
Die App läuft auf **Port 3000** und ist bereit für deinen externen Nginx Proxy Manager.

**Proxy Host Setup:**
- **Scheme**: `http`
- **Forward Hostname/IP**: `<server-ip>`
- **Forward Port**: `3000`
- **Health Check**: `/up`

### Manueller Nginx (falls gewünscht)
```nginx
server {
    listen 80;
    server_name idle-clans.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name idle-clans.yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Updates

### Code-Updates
```bash
git pull origin main
docker-compose up -d --build
```

### Database-Migrations
```bash
docker-compose -f docker-compose.production.yml exec app bundle exec rails db:migrate
```

## Backup

### Database-Backup
```bash
docker-compose -f docker-compose.production.yml exec postgres pg_dump -U postgres idle_clans_tracker_production > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore
```bash
docker-compose -f docker-compose.production.yml exec -T postgres psql -U postgres idle_clans_tracker_production < backup_file.sql
```

## Monitoring

- **Health Check**: `https://yourdomain.com/up` (Rails Standard)
- **Application**: Läuft auf Port 3000 (intern)
- **Sidekiq**: Background Jobs für API-Polling

Health Check zeigt:
- ✅ Status 200: Alles OK
- ❌ Status 500: Problem mit App/Database