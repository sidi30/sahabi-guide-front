# 🚀 SAHABI GUIDE - GUIDE DE DÉMARRAGE

## ✅ Services Démarrés

Tous les services principaux sont maintenant **opérationnels** ! Voici comment y accéder :

### 🌐 URLs d'Accès

| Service | URL | Identifiants | Statut |
|---------|-----|-------------|--------|
| **Frontend (Dashboard)** | http://localhost:3000 | Via Keycloak | ✅ Actif |
| **Backend API** | http://localhost:8084 | - | ✅ Actif |
| **API Documentation (Swagger)** | http://localhost:8084/swagger-ui.html | - | ✅ Actif |
| **Keycloak Admin** | http://localhost:8080 | admin / admin | ✅ Actif |
| **PostgreSQL** | localhost:5432 | sahabi / sahabi | ✅ Actif |

### 🔐 Keycloak - Console d'Administration

1. **Accéder à Keycloak** : Ouvrez votre navigateur et allez sur http://localhost:8080
2. **Se connecter** :
   - Cliquez sur "Administration Console"
   - **Username** : `admin`
   - **Password** : `admin`
3. **Realm Sahabi** : Le realm `sahabi` est déjà importé avec toute la configuration

### 🎨 Dashboard React

1. **Accéder au Dashboard** : http://localhost:3000
2. **Authentification** : Vous serez redirigé vers Keycloak pour vous connecter
3. **Utilisateurs de test** : Vérifiez dans Keycloak → Realm Sahabi → Users

### 🔧 API Backend

- **Health Check** : http://localhost:8084/actuator/health
- **API Documentation** : http://localhost:8084/swagger-ui.html
- **API Endpoints** : http://localhost:8084/api/v1/*

## 📋 Commandes Docker Compose

### Démarrer tous les services
```powershell
docker-compose up -d
```

### Voir l'état des services
```powershell
docker-compose ps
```

### Voir les logs d'un service
```powershell
# Backend
docker-compose logs -f backend

# Keycloak
docker-compose logs -f keycloak

# Frontend
docker-compose logs -f frontend

# PostgreSQL
docker-compose logs -f postgres
```

### Redémarrer un service
```powershell
docker-compose restart keycloak
docker-compose restart backend
```

### Arrêter tous les services
```powershell
docker-compose down
```

### Arrêter et supprimer les volumes (ATTENTION: Perte de données)
```powershell
docker-compose down -v
```

## 🔍 Vérification des Services

### 1. PostgreSQL
```powershell
docker exec sahabi-postgres psql -U sahabi -d sahabi_db -c "\dt"
```

### 2. Backend (Health Check)
```powershell
Invoke-WebRequest -Uri http://localhost:8084/actuator/health | Select-Object -Expand Content
```

### 3. Keycloak (Test du Port)
```powershell
Test-NetConnection -ComputerName localhost -Port 8080
```

### 4. Frontend
```powershell
Invoke-WebRequest -Uri http://localhost:3000 | Select-Object StatusCode
```

## 🐛 Dépannage

### Keycloak ne répond pas
1. Vérifier les logs :
```powershell
docker-compose logs keycloak --tail=50
```

2. Redémarrer Keycloak :
```powershell
docker-compose restart keycloak
```

3. Attendre 30-60 secondes pour que Keycloak démarre complètement

### Backend ne démarre pas
1. Vérifier que PostgreSQL est prêt :
```powershell
docker-compose ps postgres
```

2. Voir les logs du backend :
```powershell
docker-compose logs backend --tail=100
```

### Base de données - Créer le schéma Keycloak manuellement
```powershell
docker exec sahabi-postgres psql -U sahabi -d sahabi_db -c "CREATE SCHEMA IF NOT EXISTS keycloak; GRANT ALL ON SCHEMA keycloak TO sahabi;"
```

## 📊 Ordre de Démarrage Recommandé

Pour un démarrage contrôlé, lancez les services dans cet ordre :

```powershell
# 1. PostgreSQL d'abord
docker-compose up -d postgres

# 2. Attendre que PostgreSQL soit prêt (15 secondes)
Start-Sleep -Seconds 15

# 3. Keycloak et Backend
docker-compose up -d keycloak backend

# 4. Attendre que le backend soit prêt (30 secondes)
Start-Sleep -Seconds 30

# 5. Frontend
docker-compose up -d frontend
```

## 🔑 Configuration Keycloak

Le realm `sahabi` est automatiquement importé depuis :
```
sahabi-guide-api/keycloak/import/
```

Il contient :
- ✅ Configuration du realm
- ✅ Clients (sahabi-dashboard, sahabi-mobile)
- ✅ Rôles (ADMIN, COORDINATOR, PILGRIM, etc.)
- ✅ Mappers de protocole
- ✅ Configuration OAuth2/OIDC

## 🌐 Variables d'Environnement

Toutes les variables sont définies dans `.env` (copié depuis `env.template`).

Les principales variables :
```env
# PostgreSQL
POSTGRES_DB=sahabi_db
POSTGRES_USER=sahabi
POSTGRES_PASSWORD=sahabi

# Keycloak
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin

# Backend
SPRING_PROFILE=dev
JWT_SECRET=mySecretKeyForSahabiGuideApplicationThatIsVerySecureAndLongEnough

# Frontend
VITE_API_BASE_URL=http://localhost:8084
VITE_KEYCLOAK_URL=http://localhost:8080
```

## 🎯 Prochaines Étapes

1. ✅ **Tester Keycloak** : Accédez à http://localhost:8080 et connectez-vous avec admin/admin
2. ✅ **Tester le Backend** : Vérifiez http://localhost:8084/actuator/health
3. ✅ **Tester le Frontend** : Ouvrez http://localhost:3000
4. 🔄 **Créer des utilisateurs de test** : Via la console Keycloak
5. 🔄 **Tester l'authentification** : Connectez-vous au dashboard

## 📞 Support

Si vous rencontrez des problèmes :

1. Vérifiez que tous les services sont "healthy" : `docker-compose ps`
2. Consultez les logs du service concerné : `docker-compose logs [service]`
3. Redémarrez le service : `docker-compose restart [service]`
4. En dernier recours, redémarrez tout : `docker-compose down && docker-compose up -d`





