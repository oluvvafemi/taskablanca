# Taskablanca

A multi-organization task management app for teams, featuring Kanban boards, real-time UI updates, and role-based access.

**Live Demo:** https://taskablanca.chrisadebiyi.com/

> Demo account: `ada@hotwirelabs.dev / password`  
> Or sign up and create your own organization.

## Features

- **Multi-organization**: Users can belong to multiple orgs.
- **Role-based access**: Owner, Admin, Member.
- **Projects & tasks**: Kanban-style workflow with CRUD.
- **Real-time UI**: Hotwire (Turbo Frames & Streams).
- **Auth**: Native Rails authentication (Rails 8+).
- **Search**: Live search for tasks and projects.
- **Account lifecycle**: Self-service signup and safe account deletion.
- **Seed data**: Quick bootstrapping for demos/evaluation.

## Tech Stack

- **Backend**: Ruby on Rails 8.x, PostgreSQL
- **Frontend**: Hotwire, Haml templates, Bootstrap & Bootstrap Icons
- **Tests**: Minitest (unit & integration)
- **Containerization**: Docker & docker-compose

---

## Quick Start (Local)

### Prerequisites

- Ruby **3.3.5+**
- PostgreSQL **14+**
- Node.js & Yarn

### Setup

1. **Install deps**

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

- Rails app (port 3001 → container 80)
- PostgreSQL (port 5432)

### Environment Variables

Create `.env` file:

```env
TASKABLANCA_DATABASE_PASSWORD=your_password
RAILS_MASTER_KEY=your_master_key
```

## Deployment Notes

Designed for containerized deployment; tested with Coolify behind a Traefik reverse proxy.

Any platform that supports Docker should work (Fly.io, Render, etc.).

Ensure env vars above are set. The container runs `db:prepare` automatically; on first boot (empty DB), it will also run `db:seed` automatically.
