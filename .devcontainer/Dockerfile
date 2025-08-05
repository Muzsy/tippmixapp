FROM mcr.microsoft.com/devcontainers/flutter:latest

# Firebase CLI telepítése globálisan
RUN npm install -g firebase-tools

# Hasznos alapcsomagok
RUN apt-get update && \
    apt-get install -y git curl unzip zip && \
    rm -rf /var/lib/apt/lists/*
