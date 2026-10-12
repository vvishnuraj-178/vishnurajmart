# Multi-stage build for the C++17 Drogon application.
# Debian Trixie provides libdrogon-dev and its CMake package configuration.
FROM debian:trixie-slim AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       cmake \
       g++ \
       make \
       pkg-config \
       libdrogon-dev \
       libjsoncpp-dev \
       uuid-dev \
       libcurl4-openssl-dev \
       libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY CMakeLists.txt main.cc vishnurajmart.html ./

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel 2

# Runtime image: ship only the executable, frontend, and runtime libraries.
FROM debian:trixie-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       libdrogon1t64 \
       libcurl4t64 \
       libpq5 \
       libjsoncpp26 \
       libuuid1 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 10001 --create-home app

WORKDIR /app
COPY --from=build --chown=app:app /src/build/VishnuRajMart ./VishnuRajMart
COPY --chown=app:app vishnurajmart.html ./vishnurajmart.html

ENV PORT=8080
EXPOSE 8080
USER app

CMD ["./VishnuRajMart"]
