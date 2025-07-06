# Discord Integration Tests

Diese Tests überprüfen die Discord-Integration und Race Condition Fixes.

## Test-Arten

### 1. Unit Tests (gemockt)
- `test/jobs/api_poller_job_test.rb` - Tests für API-Polling mit Race Condition Fix
- `test/jobs/clan_activity_detector_job_test.rb` - Tests für Activity Detection Logic  
- `test/jobs/discord_notification_job_test.rb` - Tests für Discord Notifications (gemockt)

Diese Tests verwenden Mocks und senden KEINE echten Discord-Nachrichten.

### 2. Integration Tests (echt)
- `test/integration/discord_integration_test.rb` - End-to-End Tests mit echten Discord-Nachrichten

Diese Tests senden echte Nachrichten an den Test-Discord-Channel.

## Setup

### Für Unit Tests:
```bash
# Test-Datenbank einrichten (einmalig)
RAILS_ENV=test rails db:create
RAILS_ENV=test rails db:migrate
RAILS_ENV=test rails db:seed

# Unit Tests ausführen
RAILS_ENV=test rails test test/jobs/
```

### Für Integration Tests:
```bash
# Mit Test-Discord-Webhook
RAILS_ENV=test rails test test/integration/discord_integration_test.rb
```

## Umgebungsvariablen

- **Development**: `.env.development` - Test-Discord-Webhook
- **Test**: `.env.test` - Test-Discord-Webhook  
- **Production**: `.env.production` - Production-Discord-Webhook

## Was wird getestet

### Race Condition Fix
- ✅ Jobs werden mit 1 Sekunde Verzögerung gestartet
- ✅ Transaktionen sind committed bevor Jobs starten
- ✅ ClanLogs werden nur als processed markiert wenn erfolgreich

### Discord Integration
- ✅ Relevante Nachrichten werden erkannt
- ✅ ClanActivities werden erstellt
- ✅ Discord-Benachrichtigungen werden gesendet
- ✅ Fehlerbehandlung funktioniert
- ✅ Irrelevante Nachrichten werden gefiltert

### Test-Sicherheit
- ✅ Production verwendet eigenen Discord-Webhook
- ✅ Tests verwenden separaten Test-Discord-Channel
- ✅ Unit Tests sind vollständig gemockt (keine echten API-Calls)