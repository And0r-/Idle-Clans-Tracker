# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby on Rails application that tracks clan activities for the game "Idle Clans". It automatically imports clan logs via API, processes donations/withdrawals, and provides a leaderboard system with points calculation.

## Development Commands

### Setup & Installation
```bash
# Start development database services
docker-compose -f docker-compose.dev.yml up -d

# Install dependencies
bundle install

# Database setup
rails db:create
rails db:migrate
rails db:seed

# Start development server
rails server

# Start background job processing
bundle exec sidekiq
```

### Testing
```bash
# Run all tests
rails test

# Run specific test files
rails test test/models/member_test.rb
rails test test/controllers/leaderboard_controller_test.rb

# Run system tests
rails test:system
```

### Code Quality
```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Security scan with Brakeman
bundle exec brakeman
```

### Background Jobs & API
```bash
# Manually trigger API import
rails runner "ApiPollerJob.perform_now"

# Process donations from imported logs
rails runner "DonationProcessorJob.perform_now"

# Check Sidekiq web interface at http://localhost:4567
bundle exec sidekiq -e development
```

### Database Operations
```bash
# Rails console
rails console

# Database console
rails dbconsole

# Reset database (development only)
rails db:drop db:create db:migrate db:seed
```

## Architecture Overview

### Core Models

- **Member** (`app/models/member.rb`): Clan members with username as primary key. Points are calculated live from donations.
- **ClanLog** (`app/models/clan_log.rb`): Raw API data storage with duplicate prevention via unique index.
- **Donation** (`app/models/donation.rb`): Processed transactions (deposits/withdrawals) with item quantities.
- **ItemValue** (`app/models/item_value.rb`): Configurable point values for different items.

### Background Jobs

- **ApiPollerJob** (`app/jobs/api_poller_job.rb`): Fetches new clan logs from API every minute using smart pagination.
- **DonationProcessorJob** (`app/jobs/donation_processor_job.rb`): Parses clan log messages and creates donation records.

### Key Services

- **IdleClansApi** (`app/services/idle_clans_api.rb`): HTTP client for Idle Clans API with error handling.

### Controllers & Routes

- **LeaderboardController**: Main ranking display with period filtering (today/week/all).
- **MembersController**: Individual member details and transaction history.
- **Admin::ItemValuesController**: Admin interface for managing item point values.

## Data Flow

1. **ApiPollerJob** runs every minute (via Sidekiq cron)
2. Fetches new logs from `https://query.idleclans.com/api/Clan/logs/clan/RosaEinhorn`
3. Stores raw logs in **ClanLog** table with duplicate prevention
4. **DonationProcessorJob** processes unprocessed logs
5. Parses messages using regex patterns for deposits/withdrawals
6. Creates **Donation** records linked to **Member**
7. Points calculated live using **ItemValue** lookup

## Message Parsing Patterns

### Deposits
```ruby
/(?<username>\w+) added (?<quantity>\d+)x (?<item_name>.+)\./
# Examples: "Player1 added 900x Titanium bar."
```

### Withdrawals
```ruby
/(?<username>\w+) withdrew (?<quantity>\d+)x (?<item_name>.+)\.?/
# Examples: "Player1 withdrew 1x Gold sorcerer bracelet"
```

## Timezone Handling

- **Storage**: All timestamps stored in UTC
- **Display**: Europe/Zurich timezone for user interface
- **Champion calculations**: Use Zurich timezone for period boundaries

## Docker Setup

### Development
```bash
# Start support services only
docker-compose -f docker-compose.dev.yml up -d
# Then run Rails locally
```

### Production
```bash
# Full containerized deployment
docker-compose up -d
```

## Environment Configuration

Key environment variables:
- `CLAN_NAME`: Clan to track (default: "RosaEinhorn")
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection for Sidekiq
- `SECRET_KEY_BASE`: Rails secret key

## Testing Strategy

- **Unit tests**: Models and core business logic
- **Controller tests**: HTTP endpoints and authentication
- **System tests**: Full browser integration with Capybara
- **Job tests**: Background job execution and error handling

## Code Conventions

- Uses Rails 8.0+ with modern conventions
- Background jobs via Sidekiq with Redis
- Database: PostgreSQL with ActiveRecord
- Authentication: Devise for admin users
- Frontend: Hotwire (Turbo + Stimulus) for dynamic updates
- Styling: Standard Rails asset pipeline

## Common Development Tasks

### Adding New Item Types
1. Items are auto-discovered from API messages
2. Add default point values in `db/seeds.rb` 
3. Admin can configure via `/admin/item_values`

### Debugging API Issues
- Check `ApiStatus` model for last fetch status
- Review Sidekiq logs for job failures
- Test API manually: `IdleClansApi.new.fetch_clan_logs(limit: 10)`

### Point Calculation Changes
- Points calculated live in `Member#total_points`
- Uses LEFT JOIN with `item_values` table
- Missing items default to 0 points

### Adding New Time Periods
1. Add period logic to `Member.champion_for_period`
2. Update routes in `config/routes.rb`
3. Add view templates and controller actions