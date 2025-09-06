FROM mcr.microsoft.com/devcontainers/flutter:latest

# Enable Corepack (pnpm via Corepack)
RUN corepack enable

# Hasznos alapcsomagok
RUN apt-get update && \
    apt-get install -y git curl unzip zip gnupg software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Terraform CLI telepítése
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform

# Dart CLI (ha nem elérhető automatikusan)
ENV PATH="/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
