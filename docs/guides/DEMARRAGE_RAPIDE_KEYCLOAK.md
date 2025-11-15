# ⚡ DÉMARRAGE RAPIDE AVEC KEYCLOAK

## 🎯 Objectif
Démarrer votre projet **SahabiGuide** avec Keycloak en **moins de 5 minutes**.

---

## 📋 Prérequis
- ✅ Docker Desktop installé et en cours d'exécution
- ✅ Node.js installé (pour le dashboard)
- ✅ Java 17+ installé (pour le backend)

---

## 🚀 MÉTHODE 1 : Script automatique (SIMPLE)

### Windows
```powershell
.\scripts\start-with-keycloak.ps1
```

### Linux / macOS
```bash
./scripts/start-with-keycloak.sh
```

**C'est tout !** Le script fait tout pour vous. ✨

---

## 🛠️ MÉTHODE 2 : Manuel (3 étapes)

### Étape 1 : Créer `.env`
```powershell
Copy-Item env.template .env
```

Ouvrez `.env` et vérifiez ces 2 lignes :
```bash
VITE_ENABLE_KEYCLOAK=true
APP_SECURITY_ENABLED=true
```

### Étape 2 : Démarrer Keycloak
```powershell
docker-compose up -d postgres keycloak
```

⏳ Attendez 1-2 minutes. Vérifiez : http://localhost:8080/health

### Étape 3 : Démarrer Backend + Dashboard

**Terminal 1 - Backend :**
```powershell
cd sahabi-guide-api
$env:APP_SECURITY_ENABLED="true"
./mvnw spring-boot:run
```

**Terminal 2 - Dashboard :**
```powershell
cd sahabi-guide-dashboard
$env:VITE_ENABLE_KEYCLOAK="true"
npm run dev
```

---

## 🔑 Créer un utilisateur

1. Ouvrez http://localhost:8080/admin
2. Connectez-vous : `admin` / `admin123`
3. Realm **sahabi** → **Users** → **Add user**
4. Créez :
   - Username : `testadmin`
   - Email : `testadmin@sahabi.local`
   - Email Verified : **ON**
5. Onglet **Credentials** → Password : `admin123`
6. Onglet **Role Mappings** → Ajouter `SUPER_ADMIN`

---

## ✅ Tester

1. Ouvrez http://localhost:3000
2. Vous êtes redirigé vers Keycloak
3. Connectez-vous : `testadmin` / `admin123`
4. Vous êtes dans le dashboard ! 🎉

---

## ❌ Problèmes ?

### Dashboard en mode TEST
```powershell
# Vérifiez la console (F12)
# Si vous voyez "Mode TEST activé" :
$env:VITE_ENABLE_KEYCLOAK="true"
cd sahabi-guide-dashboard
npm run dev
```

### Backend refuse les requêtes (401)
```powershell
# Vérifiez la variable
$env:OIDC_ISSUER_URI="http://localhost:8080/realms/sahabi"
cd sahabi-guide-api
./mvnw spring-boot:run
```

### Keycloak ne démarre pas
```powershell
# Redémarrez
docker-compose down
docker-compose up -d postgres keycloak

# Attendez et vérifiez
docker logs sahabi-keycloak
```

---

## 📚 Documentation complète

- [Guide complet](docs/guides/DEMARRAGE_AVEC_KEYCLOAK.md)
- [Analyse du problème](ANALYSE_CONNEXION_SANS_KEYCLOAK.md)
- [Résumé](RESUME_PROBLEME_KEYCLOAK.md)

---

## 🎯 Checklist rapide

- [ ] Docker en cours d'exécution
- [ ] `.env` créé avec `VITE_ENABLE_KEYCLOAK=true`
- [ ] Keycloak démarré et accessible
- [ ] Utilisateur créé dans Keycloak
- [ ] Backend lancé avec variables correctes
- [ ] Dashboard lancé avec variables correctes
- [ ] Connexion réussie !

**Vous êtes prêt à développer ! 🚀**


