# VishnuRajMart

VishnuRajMart is a C++17 + Drogon shopping marketplace with a PostgreSQL database and an HTML/CSS/JavaScript frontend.

## Files
- `main.cc` — backend routes and application logic
- `vishnurajmart.html` — frontend
- `CMakeLists.txt` — CMake build configuration
- `MODULES.md` — project modules and current status
- `DEVELOPMENT_COMMITS.md` — planned milestones
- `DEPLOYMENT.md` — deployment instructions

## Important
- Configure the environment variables documented in `DEPLOYMENT.md`; never commit real passwords, API keys, or database connection strings.
- The CMake build needs Drogon, libcurl, and PostgreSQL development libraries available.
- This folder was renamed/rebranded from the supplied project files. The build and live deployment have not been tested in this environment.