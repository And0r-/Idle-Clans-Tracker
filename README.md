# Idle Clans Tracker

Ein Rails-basiertes Web-Dashboard zur Überwachung und Auswertung von Clan-Aktivitäten im Spiel "Idle Clans".

## Projektübersicht

Diese Anwendung importiert minütlich Clan-Log-Daten über die öffentliche Idle Clans API, verarbeitet Spenden und Abhebungen, und stellt ein Ranking-System mit Einhornpunkten zur Verfügung.

### Hauptfunktionen

- **Automatischer Import**: Jede Minute werden neue Clan-Logs von der API abgerufen
- **Spenden-Tracking**: Erfassung aller Ein- und Auszahlungen von Clan-Mitgliedern
- **Punktesystem**: Umrechnung von Gold und Items in Einhornpunkte
- **Leaderboard**: Rangliste aller Mitglieder basierend auf ihren Spenden
- **Detail-Ansichten**: Vollständige Transaktionshistorie pro Mitglied
- **Admin-Interface**: Bearbeitung der Punktwerte für Items

## Technischer Stack

- **Rails**: 7.2.1
- **Database**: PostgreSQL (neueste Version)
- **Background Jobs**: Sidekiq + Redis
- **Containerization**: Docker + Docker Compose
- **Timezone**: UTC (Speicher) / Europe/Zurich (Anzeige)

## API-Integration

### Idle Clans API Endpoint
```
GET https://query.idleclans.com/api/Clan/logs/clan/RosaEinhorn
```

**Query Parameters:**
- `skip` (integer): Anzahl zu überspringender Logs (Default: 0)
- `limit` (integer): Maximale Anzahl Logs (Default: 100, Max: 100)

**Limitation**: Nur Daten der letzten 14 Tage verfügbar

### API Response Format
```json
[
  {
    "clanName": "RosaEinhorn",
    "memberUsername": "S1l3ntd4rk",
    "message": "S1l3ntd4rk completed a combat quest!",
    "timestamp": "2025-05-25T08:37:47.646Z"
  }
]
```

## Datenmodell

### Models

#### Member
```ruby
# Clan-Mitglieder
- username: string (primary key, unique)
- total_points: decimal (default: 0)
- created_at: datetime
- updated_at: datetime
```

#### ClanLog
```ruby
# Rohe API-Daten (für Duplikat-Vermeidung)
- clan_name: string
- member_username: string
- message: text
- timestamp: datetime
- created_at: datetime
- updated_at: datetime

# Unique Index: [member_username, message, timestamp]
```

#### Donation
```ruby
# Verarbeitete Spenden/Abhebungen
- member: references (Member)
- transaction_type: enum ['deposit', 'withdraw']
- item_name: string
- quantity: integer
- points_value: decimal
- raw_message: text
- occurred_at: datetime
- created_at: datetime
- updated_at: datetime
```

#### ItemValue
```ruby
# Konfigurierbare Punktwerte für Items
- item_name: string (unique)
- points_per_unit: decimal
- active: boolean (default: true)
- created_at: datetime
- updated_at: datetime
```

### Standardwerte für ItemValue
```ruby
# Diese werden beim Setup angelegt:
{ item_name: "Gold", points_per_unit: 1.0 }
{ item_name: "Titanium bar", points_per_unit: 3350.0 }
{ item_name: "Magical plank", points_per_unit: 264.0 }
```

## Message Parsing

### Erkannte Nachrichten-Typen

**Deposits (Spenden):**
- `"USERNAME added 900x Titanium bar."`
- `"USERNAME added 300710x Gold."`
- `"USERNAME added 1x Toolbelt."`

**Withdrawals (Abhebungen):**
- `"USERNAME withdrew 1x Gold sorcerer bracelet"`
- `"USERNAME withdrew 1x Gold precision symbol."`

**Ignorierte Nachrichten:**
- `"USERNAME completed a combat quest!"`
- `"USERNAME completed a skilling quest!"`

### Parsing-Regex
```ruby
# Deposits
/(?<username>\w+) added (?<quantity>\d+)x (?<item_name>.+)\./

# Withdrawals  
/(?<username>\w+) withdrew (?<quantity>\d+)x (?<item_name>.+)\.?/
```

## Background Jobs

### ApiPollerJob
- **Frequenz**: Jede Minute
- **Funktion**: Abruf neuer Clan-Logs von der API
- **Duplikat-Handling**: Überprüfung via Timestamp des letzten Imports
- **Pagination**: Smart Skip/Limit für größere Datenmengen

### DonationProcessorJob
- **Trigger**: Nach jedem API-Import
- **Funktion**: Verarbeitung neuer ClanLogs zu Donation-Records
- **Punktberechnung**: Automatische Umrechnung basierend auf ItemValue-Tabelle

## Web-Interface

### Routes
```ruby
# Hauptseiten
root 'leaderboard#index'                    # Rangliste
get 'members/:username', to: 'members#show' # Mitglieder-Details

# Admin-Bereich
namespace :admin do
  resources :item_values                     # Item-Punktwerte bearbeiten
  resources :clan_logs, only: [:index]      # Log-Übersicht
  post 'sync_now', to: 'sync#create'        # Manueller Sync
end
```

### Views

#### Leaderboard (`/`)
- Tabelle aller Mitglieder sortiert nach total_points
- Spalten: Rang, Username, Gesamtpunkte, Letzte Aktivität
- Links zu Detail-Ansichten

#### Member Details (`/members/:username`)
- Vollständige Transaktionshistorie
- Aufschlüsselung nach Items
- Punkte-Verlauf über Zeit
- Separate Darstellung von Deposits und Withdrawals

#### Admin: Item Values (`/admin/item_values`)
- CRUD-Interface für Punktwerte
- Aktivierung/Deaktivierung von Items
- Bulk-Updates möglich

## Setup & Installation

### Voraussetzungen
- Docker & Docker Compose
- Git

### Installation
```bash
# Repository klonen
git clone <repository-url>
cd idle-clans-tracker

# Environment-Variablen konfigurieren
cp .env.example .env
# Bearbeite .env nach Bedarf

# Container starten
docker-compose up -d

# Database Setup
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed

# Erste Daten importieren
docker-compose exec web rails runner "ApiPollerJob.perform_now"
```

### Environment-Variablen (.env)
```env
# Database
POSTGRES_DB=idle_clans_tracker
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password

# Redis
REDIS_URL=redis://redis:6379/0

# Rails
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key

# API Configuration
CLAN_NAME=RosaEinhorn
API_POLL_INTERVAL=60 # Sekunden
```

### Docker Compose Services
```yaml
# web: Rails App
# postgres: PostgreSQL Database  
# redis: Redis für Sidekiq
# sidekiq: Background Job Worker
```

## Entwicklung

### Wichtige Commands
```bash
# Logs anzeigen
docker-compose logs -f web
docker-compose logs -f sidekiq

# Rails Console
docker-compose exec web rails console

# Tests ausführen
docker-compose exec web rails test

# Manueller API-Import
docker-compose exec web rails runner "ApiPollerJob.perform_now"

# Sidekiq Web-Interface
# Verfügbar unter: http://localhost:3000/sidekiq
```

### Debugging

#### Häufige Probleme

**API-Import funktioniert nicht:**
- Prüfe Sidekiq-Logs: `docker-compose logs sidekiq`
- Teste manuell: `ApiPollerJob.perform_now`
- Prüfe API-Erreichbarkeit

**Duplikate in der Datenbank:**
- Prüfe Unique-Constraints in ClanLog
- Überprüfe Timestamp-Handling

**Punkteberechnung falsch:**
- Prüfe ItemValue-Einträge: `ItemValue.all`
- Teste Message-Parsing: `DonationProcessorJob.perform_now`

## Deployment

### Production Checklist
- [ ] Environment-Variablen konfiguriert
- [ ] Database-Backups eingerichtet
- [ ] SSL-Zertifikate installiert
- [ ] Monitoring aufgesetzt (Sidekiq Web UI)
- [ ] Log-Rotation konfiguriert

### Monitoring
- **Sidekiq Web**: `/sidekiq` (Admin-Login erforderlich)
- **Health Check**: `/health` (API-Status, DB-Connection)
- **Metrics**: `/metrics` (Prometheus-kompatibel)

## API-Dokumentation

### Interne API-Endpoints
```ruby
# JSON-Endpoints für AJAX-Updates
GET /api/members/:username/donations.json
GET /api/leaderboard.json
GET /api/sync_status.json
```

## Roadmap / Zukünftige Features

### Phase 2
- [ ] Zeitraum-Filter für Leaderboard (7 Tage, 30 Tage, etc.)
- [ ] Withdraw-Daten in Ranking einbeziehen
- [ ] Export-Funktionen (CSV, JSON)
- [ ] Email-Benachrichtigungen bei großen Spenden

### Phase 3
- [ ] Multi-Clan Support
- [ ] Grafische Statistiken (Charts.js)
- [ ] Mobile-optimierte Ansicht
- [ ] API-Rate-Limiting und Caching

## Sicherheit

### Authentifizierung
- Admin-Bereich durch HTTP Basic Auth geschützt
- Keine öffentliche Schreibzugriffe auf kritische Daten

### Validierung
- Input-Sanitization für alle User-Daten
- SQL-Injection-Schutz durch ActiveRecord
- XSS-Schutz durch Rails-Standards

## Wartung


---

## Kontakt & Support

Bei Fragen oder Problemen:
1. Issues in diesem Repository erstellen
2. Logs sammeln (`docker-compose logs`)
3. Aktuelle Rails/Sidekiq-Versionen angeben

**Entwickelt für den Clan "RosaEinhorn" in Idle Clans**
