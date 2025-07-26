# Demurrage Invoice System

A Rails 7.2 application for managing demurrage invoices for import cargo operations, built to modernize and improve upon a legacy French MySQL database system.

## Overview

This system automates the generation of demurrage invoices for Bills of Lading (BLs) that exceed their free time allowance. When cargo containers remain at the port beyond the allowed free period, customers are charged a daily demurrage fee.

## Quick Setup

### Prerequisites
- Ruby 3.x
- Rails 7.x
- MySQL 8.x
- Bundler

### Installation

1. Clone the repository and install dependencies:
```bash
bundle install
```

2. Configure database credentials in `config/database.yml`. See .env.example for .env keys

3. Import the legacy schema:
```bash
mysql -u your_user -p your_database < test_schema.sql
```

4. Run the migrations:
```bash
rails db:migrate
```

5Run the seeder:
```bash
rails db:seed
```

6. Start the application:
```bash
rails server
```

7. To Run Test:
```bash
rspec --format documentation
```

7. To Test the Endpoint:
```bash
curl -X POST http://localhost:3000/api/v1/invoices
```

## API Endpoints

### Generate Invoices
**POST** `/api/v1/invoices`

Triggers the daily invoice generation process for BLs that became overdue today.

**Response:**
```json
{
  "message": "Invoice Generation Operation Completed",
  "count": 5,
  "timestamp": "2025-07-26T10:30:00Z"
}
```

### View Overdue Invoices
**GET** `/invoices`

Returns an HTML table listing all currently overdue invoices.

## License

MIT