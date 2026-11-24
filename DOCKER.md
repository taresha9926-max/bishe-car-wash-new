# Docker Deployment Guide for BISHE Car Wash & Umami Analytics

This project is fully dockerized with a multi-container Docker Compose architecture.

---

## 1. Quick Start (Windows)

1. Make sure **Docker Desktop** is running.
2. Double-click `start_app_docker.bat` (or execute `docker compose up -d --build`).
3. Services will be available at:
   * **BISHE Car Wash Web Application:** [http://localhost:8080](http://localhost:8080)
   * **Umami Analytics Dashboard:** [http://localhost:3000](http://localhost:3000)
   * **PostgreSQL Database (Umami):** `localhost:5432`

To stop all containers, double-click `stop_app_docker.bat` or run:
```bash
docker compose down
```

---

## 2. Architecture Overview

```
                      +-----------------------------+
                      |   Client Browser / Mobile   |
                      +--------------+--------------+
                                     |
             +-----------------------+-----------------------+
             |                                               |
             v :8080                                         v :3000
+-------------------------+                     +-------------------------+
|   bishe-car-wash-app    |                     |       bishe-umami       |
|  (Nginx Alpine + SPA)   |                     | (Umami Analytics Engine)|
+-------------------------+                     +------------+------------+
                                                             |
                                                             v :5432
                                                +-------------------------+
                                                |     bishe-umami-db      |
                                                |  (Postgres 15 Alpine)   |
                                                +-------------------------+
```

* **App Service (`app`)**:
  - Serves the production Flutter Web release bundle (`build/web`) via `nginx:1.27-alpine`.
  - Configured with SPA rewrite routing (`try_files $uri $uri/ /index.html`).
  - Gzip compression and long-lived immutable caching for CanvasKit/Wasm, fonts, and assets.
  - Built-in `/healthz` healthcheck.

* **Umami Analytics Service (`umami`)**:
  - Official Umami container (`ghcr.io/umami-software/umami:postgresql-latest`).
  - Pre-configured cryptographic `APP_SECRET` and encryption keys.
  - Tracks website visits, user roles, and custom operational events.

* **Database Service (`umami-db`)**:
  - PostgreSQL 15 Alpine with persistent volume `bishe-umami-db-data`.

---

## 3. Vercel & Cloud Deployment Compatibility

The Docker setup is isolated and protected so it does **not** interfere with Vercel:
* `.vercelignore` excludes `Dockerfile` and `docker-compose.yml`.
* `vercel.json` continues to serve `build/web` with pure static routing.
* GitHub Pages deploy workflow remains fully operational.
