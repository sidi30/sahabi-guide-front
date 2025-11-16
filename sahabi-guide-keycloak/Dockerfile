#######################################################
# 🚀 GOOGLE CLOUD RUN - DOCKERFILE POUR KEYCLOAK
#######################################################
# Optimisé pour Cloud Run avec :
# - Image officielle Keycloak
# - Support de la variable PORT (Cloud Run)
# - Configuration PostgreSQL Cloud SQL
# - Import automatique du realm
# - Proxy headers pour Cloud Run
#######################################################

FROM quay.io/keycloak/keycloak:26.1.0 AS builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

# Build optimized image
WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build

#######################################################
# RUNTIME STAGE
#######################################################
FROM quay.io/keycloak/keycloak:26.1.0

# Copier la build optimisée
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Copier le realm à importer
USER root
RUN mkdir -p /opt/keycloak/data/import
COPY sahabi-realm.json /opt/keycloak/data/import/sahabi-realm.json
RUN chown -R keycloak:keycloak /opt/keycloak/data
USER keycloak

WORKDIR /opt/keycloak

# ===========================================
# VARIABLES D'ENVIRONNEMENT POUR CLOUD RUN
# ===========================================
# Ces variables seront fournies au runtime par Cloud Run

# Database (Cloud SQL via socket ou connexion directe)
ENV KC_DB=postgres
ENV KC_DB_URL_HOST=${DB_HOST:-localhost}
ENV KC_DB_URL_PORT=${DB_PORT:-5432}
ENV KC_DB_URL_DATABASE=${DB_NAME:-keycloak}
ENV KC_DB_USERNAME=${DB_USER:-keycloak}
ENV KC_DB_PASSWORD=${DB_PASSWORD:-keycloak}
ENV KC_DB_SCHEMA=public

# Hostname configuration (à définir via variables Cloud Run)
ENV KC_HOSTNAME=${KEYCLOAK_HOSTNAME:-localhost}
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false

# HTTP/Proxy Configuration pour Cloud Run
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8080
ENV KC_PROXY_HEADERS=xforwarded
ENV KC_PROXY=edge

# Health et Metrics
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Logging
ENV KC_LOG_LEVEL=INFO


# Cloud Run utilise la variable PORT (par défaut 8080)
EXPOSE 8080

# Healthcheck pour Cloud Run
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=5 \
    CMD curl -f http://localhost:${PORT:-8080}/health/ready || exit 1

# Utiliser la commande de démarrage standard de Keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm"]

