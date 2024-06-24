FROM ghcr.io/actions/actions-runner:2.317.0
# for latest release, see https://github.com/actions/runner/releases

USER root

# install:
# - curl, jq, Azure CLI, PostgreSQL client, and dnsutils
# - unzip, nodejs with npm via nvm: used by hashicorp/setup-terraform
# Installs the rdbms-connect az-cli extension to allow az postgres flexible-server connect
RUN apt-get update && \
    apt-get install -y curl jq apt-transport-https lsb-release gnupg dnsutils unzip && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft-archive-keyring.gpg && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && \
    apt-get install -y azure-cli && \
    az extension add --name rdbms-connect && \
    curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /usr/share/keyrings/postgresql-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-client-16 && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    sudo apt-get install -y nodejs && \
    node -v && npm -v && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

USER runner

ENTRYPOINT ["./entrypoint.sh"]
