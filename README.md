# Taskablanca

A multi-organization task management application.

## Features

- **Multi-Organization Support**: Users can create and be added to multiple organizations
- **Role-Based Access**: Owner, Admin, and Member roles
- **Project Management**: Create and manage projects within organizations
- **Task Tracking**: Kanban-style task management
- **User Registration**: Account creation with automatic organization setup
- **Account Closure**: Safe account deletion with ownership checks

## Development

### Prerequisites

- Ruby 3.3.5+
- PostgreSQL 14+

### Local Setup

1. **Install dependencies**

   ```bash
   bundle install
   yarn install
   yarn build
   yarn build:css
   ```

2. **Setup database**

   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

3. **Start server**

   ```bash
   bin/dev
   ```

4. **Access the app**
   - http://localhost:3000
   - Test users: ada@hotwirelabs.dev / password

### Testing

```bash
bin/rails test
```

## Docker Deployment

### One-Command Deployment

```bash
docker-compose up -d
```

This starts:

- Rails app (port 3000)
- PostgreSQL (port 5432)

### Environment Variables

Create `.env` file:

```env
POSTGRES_PASSWORD=your_password
RAILS_MASTER_KEY=your_master_key
```
