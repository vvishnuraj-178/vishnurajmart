# VishnuRajMart

VishnuRajMart is a C++17 + Drogon shopping marketplace with a PostgreSQL database and an HTML/CSS/JavaScript frontend.

## Files
- `main.cc` — backend routes and application logic
- `vishnurajmart.html` — frontend
- `CMakeLists.txt` — CMake build configuration
- `Dockerfile` — multi-stage container build for Koyeb
- `schema.sql` — schema for a new/empty Neon database
- `MODULES.md` — project modules and current status
- `DEVELOPMENT_COMMITS.md` — planned milestones
- `DEPLOYMENT.md` — deployment instructions

## Important
- Follow the Koyeb + Neon deployment guide in `DEPLOYMENT.md`; configure its environment variables; never commit real passwords, API keys, or database connection strings.
- The CMake build needs Drogon, libcurl, and PostgreSQL development libraries available.
- This folder was renamed/rebranded from the supplied project files. The Docker build and live deployment must still be verified in Koyeb build/runtime logs.