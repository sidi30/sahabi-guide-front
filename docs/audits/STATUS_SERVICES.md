# ✅ SAHABI GUIDE - TOUS LES SERVICES SONT OPÉRATIONNELS !

## 🎯 État Actuel des Services

| Service | Statut | Port | URL d'accès |
|---------|--------|------|-------------|
| **PostgreSQL** | ✅ Healthy | 5432 | localhost:5432 |
| **Keycloak** | ✅ Running | 8080 | http://localhost:8080 |
| **Backend API** | ✅ Healthy | 8084 | http://localhost:8084 |
| **Frontend Dashboard** | ✅ Running | 3000 | http://localhost:3000 |

## 🔐 Accès à Keycloak

### Console d'Administration
1. Ouvrez votre navigateur : **http://localhost:8080**
2. Cliquez sur "Administration Console"
3. Connectez-vous avec :
   - **Username** : `admin`
   - **Password** : `admin`

### Realm Sahabi
Le realm `sahabi` a été automatiquement importé avec :
- ✅ Configuration OAuth2/OIDC
- ✅ Clients (sahabi-dashboard, sahabi-mobile)
- ✅ Rôles utilisateurs
- ✅ Mappers de protocole

## 🎨 Accès au Dashboard

1. Ouvrez : **http://localhost:3000**
2. Vous serez redirigé vers Keycloak pour vous authentifier
3. Après connexion, vous accédez au dashboard

## 🔧 Accès à l'API Backend

- **Health Check** : http://localhost:8084/actuator/health
- **Swagger UI** : http://localhost:8084/swagger-ui.html
- **API Base** : http://localhost:8084/api/v1

## 📊 Vérification Rapide

### Tester Keycloak
```powershell
Invoke-WebRequest -Uri http://localhost:8080 | Select-Object StatusCode
# Résultat attendu : StatusCode : 200
```

### Tester le Backend
```powershell
Invoke-WebRequest -Uri http://localhost:8084/actuator/health | Select-Object -Expand Content
# Résultat attendu : {"status":"UP"}
```

### Tester le Frontend
```powershell
Invoke-WebRequest -Uri http://localhost:3000 | Select-Object StatusCode
# Résultat attendu : StatusCode : 200
```

### Voir l'état de tous les services
```powershell
docker-compose ps
```

## 📋 Commandes Utiles

### Voir les logs en direct
```powershell
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f keycloak
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Redémarrer un service
```powershell
docker-compose restart keycloak
docker-compose restart backend
docker-compose restart frontend
```

### Arrêter tous les services
```powershell
docker-compose down
```

### Redémarrer tous les services
```powershell
docker-compose up -d
```

## 🔑 Identifiants par Défaut

### Keycloak Admin
- URL : http://localhost:8080
- Username : `admin`
- Password : `admin`

### PostgreSQL
- Host : `localhost`
- Port : `5432`
- Database : `sahabi_db`
- Username : `sahabi`
- Password : `sahabi`

## 🎯 Prochaines Étapes

1. **Créer des utilisateurs de test dans Keycloak** :
   - Connectez-vous à la console d'administration
   - Sélectionnez le realm "sahabi"
   - Allez dans "Users" → "Add user"
   - Créez un utilisateur et définissez son mot de passe

2. **Tester l'authentification** :
   - Ouvrez http://localhost:3000
   - Connectez-vous avec l'utilisateur créé
   - Explorez le dashboard

3. **Tester l'API** :
   - Ouvrez http://localhost:8084/swagger-ui.html
   - Testez les endpoints disponibles

## 🐛 Dépannage

### Si un service ne répond pas
```powershell
# Voir les logs du service
docker-compose logs [service_name] --tail=50

# Redémarrer le service
docker-compose restart [service_name]
```

### Si Keycloak ne démarre pas
```powershell
# Vérifier les logs
docker-compose logs keycloak --tail=100

# Redémarrer Keycloak
docker-compose restart keycloak
```

### Pour un redémarrage complet
```powershell
# Arrêter tout
docker-compose down

# Redémarrer tout
docker-compose up -d

# Attendre 1 minute pour que tout démarre
Start-Sleep -Seconds 60

# Vérifier l'état
docker-compose ps
```

## 📝 Notes Importantes

- ⚠️ **Keycloak en mode développement** : Le message "Running the server in development mode. DO NOT use this configuration in production" est normal pour l'environnement local.

- ⚠️ **Health Check** : Keycloak peut rester en "health: starting" pendant quelques minutes, c'est normal. Il est déjà fonctionnel sur http://localhost:8080.

- ✅ **Configuration automatique** : Tous les services sont pré-configurés et communiquent entre eux automatiquement.

- ✅ **Volumes persistants** : Les données PostgreSQL sont conservées même après un `docker-compose down`.

## 🚀 Tout est Prêt !

Vos services Sahabi Guide sont maintenant **100% opérationnels** et prêts à être utilisés !

🌐 **Accédez au dashboard** : http://localhost:3000
🔐 **Console Keycloak** : http://localhost:8080
🔧 **API Swagger** : http://localhost:8084/swagger-ui.html





