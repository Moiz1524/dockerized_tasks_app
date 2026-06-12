# Dockerized Tasks App

A learning project demonstrating how to containerize a Ruby on Rails application using Docker and Docker Compose. It covers a realistic multi-service setup including a web server, background job worker, CSS watcher, PostgreSQL database, and Redis.

## What This Project Covers

- Multi-service Docker Compose setup for a Rails app
- PostgreSQL as the primary database
- Sidekiq + Redis for background job processing
- Sending emails asynchronously via Active Job + ActionMailer
- Hotwire (Turbo Streams) for real-time UI updates without full page reloads
- Tailwind CSS with a live watcher process
- Health checks and startup ordering between services

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Docker Compose                      │
│                                                      │
│  ┌─────────┐   ┌──────────┐   ┌───────────────────┐ │
│  │   web   │   │  worker  │   │       css         │ │
│  │  Rails  │   │ Sidekiq  │   │ tailwindcss:watch │ │
│  │ :3000   │   │          │   │                   │ │
│  └────┬────┘   └────┬─────┘   └───────────────────┘ │
│       │             │                                │
│  ┌────▼─────────────▼────┐   ┌────────────────────┐ │
│  │       postgres        │   │       redis         │ │
│  │     PostgreSQL 16     │   │     Redis 7         │ │
│  │        :5432          │   │      :6379          │ │
│  └───────────────────────┘   └────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

| Service    | Role                                                   |
|------------|--------------------------------------------------------|
| `web`      | Puma web server serving the Rails app on port 3000     |
| `worker`   | Sidekiq process consuming jobs from the Redis queue    |
| `css`      | Tailwind CSS watcher — recompiles styles on file change|
| `postgres` | PostgreSQL 16 — primary application database           |
| `redis`    | Redis 7 — Sidekiq's job queue backing store            |

## Tech Stack

- **Ruby** 4.0.3
- **Rails** 8.1.3
- **PostgreSQL** 16
- **Redis** 7
- **Sidekiq** — background job processing
- **Hotwire** (Turbo + Stimulus) — reactive UI
- **Tailwind CSS** — utility-first styling
- **Propshaft** — asset pipeline
- **Thruster** — HTTP caching/compression proxy in front of Puma

## Features

- Create, edit, delete, and duplicate tasks
- Each task has a title, description, status (`pending` / `in_progress` / `completed`), priority (`low` / `medium` / `high`), and due date
- Creating a task enqueues a background job (`TaskCreatedJob`) that sends an email notification via `TaskMailer`
- UI updates happen via Turbo Streams — no full page reloads
- Sidekiq dashboard available at `/sidekiq`

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

That's it. No local Ruby, PostgreSQL, or Redis installation required.

## Getting Started

### 1. Fix the Dockerfile for development

The default `Dockerfile` excludes development gems. Open it and change line 21:

```dockerfile
# Before
BUNDLE_WITHOUT="development"

# After
BUNDLE_WITHOUT=""
```

This ensures gems like `letter_opener` (email preview) are installed in the image.

### 2. Build the images

```bash
docker compose build
```

This compiles the Rails image — runs `bundle install`, bootsnap precompile, and asset precompile. Takes a few minutes the first time.

### 3. Start all services

```bash
docker compose up
```

On first boot, the web container automatically runs `db:prepare` (creates the database and runs all migrations). Watch the logs — once you see `Listening on http://0.0.0.0:3000`, the app is ready.

### 4. Open the app

```
http://localhost:3000
```

The Sidekiq dashboard is available at:

```
http://localhost:3000/sidekiq
```

## Common Commands

```bash
# Start in detached (background) mode
docker compose up -d

# Tail logs for all services
docker compose logs -f

# Tail logs for a specific service
docker compose logs -f web
docker compose logs -f worker

# Open a Rails console
docker compose exec web ./bin/rails console

# Run database migrations
docker compose exec web ./bin/rails db:migrate

# Check service status
docker compose ps

# Stop all services (data is preserved)
docker compose down

# Stop all services and wipe all data (postgres + redis volumes)
docker compose down -v
```

## How the Background Job Flow Works

```
User creates task
      │
      ▼
TasksController#create
      │
      ├── saves Task to PostgreSQL
      │
      └── TaskCreatedJob.perform_later(task)
                │
                ▼
           Redis queue
                │
                ▼
        Sidekiq worker picks it up
                │
                ▼
      TaskMailer.task_created(task).deliver_later
                │
                ▼
        Email preview opens in browser (letter_opener)
```

## Project Structure

```
├── app/
│   ├── controllers/tasks_controller.rb   # CRUD + copy actions
│   ├── jobs/task_created_job.rb          # Enqueued on task creation
│   ├── mailers/task_mailer.rb            # Sends task notification email
│   └── models/task.rb                   # Task model with validations
├── config/
│   ├── database.yml                      # PostgreSQL config (reads DATABASE_URL)
│   ├── sidekiq.yml                       # Queue definitions: default, mailers
│   └── environments/development.rb       # Sets Sidekiq as job adapter
├── Dockerfile                            # Production-style multi-stage build
├── compose.yml                           # Multi-service Docker Compose setup
└── Procfile.dev                          # Local dev process definitions
```

## Environment Variables

These are set in `compose.yml` and consumed by the Rails app at runtime:

| Variable       | Value (in Docker)                                               | Purpose                        |
|----------------|-----------------------------------------------------------------|--------------------------------|
| `DATABASE_URL`  | `postgres://postgres:password@postgres:5432/...`               | Overrides database.yml host    |
| `REDIS_URL`     | `redis://redis:6379/0`                                         | Sidekiq connection URL         |
| `RAILS_ENV`     | `development`                                                   | Rails environment              |

## Volumes

| Volume          | Purpose                                              |
|-----------------|------------------------------------------------------|
| `postgres_data` | Persists database across container restarts          |
| `redis_data`    | Persists Sidekiq queue state across restarts         |
| `bundle_cache`  | Caches installed gems to speed up rebuilds           |
