# 🚀 Démarrage rapide SANS Keycloak (Mode DEV)

## ✅ Ce que je viens de corriger

### Problème identifié
- Keycloak n'est pas démarré (port 8081 fermé)
- Dashboard React bloqué sur "Chargement..." indéfiniment

### Corrections appliquées

1. **`AuthContext.tsx`** : Ajout d'un timeout de 5 secondes
   - Si Keycloak ne répond pas → Continue en mode DEV sans authentification
   - Message dans la console : `⚠️ Keycloak timeout - Mode DEV sans authentification`

2. **`application-dev.yml`** : Désactivation temporaire de la sécurité backend
   - `app.security.enabled: false`
   - Tous les endpoints sont accessibles sans token

---

## 🏃 Démarrage immédiat

### 1. Backend (si pas déjà lancé)
```bash
cd sahabi-guide-api
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### 2. Dashboard
```bash
cd sahabi-guide-dashboard

# Arrêter le serveur actuel (Ctrl+C)
# Puis relancer :
npm run dev
```

### 3. Ouvrir le navigateur
```
http://localhost:3000
```

**Résultat attendu** :
- Après 5 secondes max, l'app se débloque
- Console navigateur : `⚠️ Keycloak timeout - Mode DEV sans authentification`
- Dashboard s'affiche normalement
- Tous les endpoints fonctionnent (pas d'authentification requise)

---

## ⚠️ **Limitations en mode DEV sans Keycloak**

| Fonctionnalité | État |
|----------------|------|
| Navigation Dashboard | ✅ Fonctionne |
| Appels API Backend | ✅ Fonctionne (pas de contrôle d'accès) |
| Métriques, POIs, Alertes | ✅ Fonctionne |
| Bouton "Se connecter" | ⚠️ Redirige vers Keycloak (erreur si non lancé) |
| Rôles & autorisations | ❌ Non testable (pas de JWT) |
| Mobile Flutter | ✅ Fonctionne normalement (auth indépendante) |

---

## 🔐 Passer en mode PRODUCTION (avec Keycloak)

### Quand tu veux activer Keycloak :

#### 1. Lancer Keycloak
```bash
# Option A : Docker
docker run -p 8081:8081 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_HTTP_PORT=8081 \
  quay.io/keycloak/keycloak:26.0.7 \
  start-dev --http-port=8081

# Option B : Docker Compose
docker-compose -f docker-compose-keycloak.yml up -d

# Vérifier :
# PowerShell
Test-NetConnection -ComputerName localhost -Port 8081

# Ou ouvrir dans le navigateur :
http://localhost:8081/admin
# Login: admin / admin
```

#### 2. Configurer Keycloak
```
Voir : INSTALLATION_KEYCLOAK_COMPLETE.md
- Créer realm: sahabi
- Créer rôles: SUPER_ADMIN, AGENCE_ADMIN, AGENCE_USER
- Créer client: sahabi-dashboard
- Créer user: admin@sahabi.com / password123
```

#### 3. Réactiver la sécurité backend
```yaml
# sahabi-guide-api/src/main/resources/application-dev.yml
app:
  security:
    enabled: true  # Remettre à true
```

#### 4. Redémarrer Backend + Dashboard
```bash
# Backend
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Dashboard
npm run dev
```

#### 5. Tester
```
1. Ouvrir http://localhost:3000/login
2. Cliquer "Se connecter"
3. Redirection Keycloak → Login admin@sahabi.com / password123
4. Redirection retour Dashboard → ✅ Authentifié
```

---

## 🔧 Troubleshooting

### Dashboard reste bloqué sur "Chargement..."
```bash
# 1. Vérifier la console navigateur (F12)
# Doit afficher : "⚠️ Keycloak timeout - Mode DEV sans authentification"

# Si rien ne s'affiche après 5 secondes :
# → Vider le cache navigateur (Ctrl+Shift+Delete)
# → Recharger (Ctrl+F5)
```

### Erreur "401 Unauthorized" sur les appels API
```bash
# Vérifier que la sécurité backend est bien désactivée :
cd sahabi-guide-api
grep "enabled:" src/main/resources/application-dev.yml

# Doit afficher :
#   enabled: ${APP_SECURITY_ENABLED:false}

# Si c'est "true" :
# 1. Changer à "false"
# 2. Redémarrer backend : mvn spring-boot:run
```

### Erreur "Cannot read properties of null"
```bash
# Vider le localStorage du navigateur :
# F12 → Console → Taper :
localStorage.clear()
location.reload()
```

---

## 📊 Comparaison modes

| | DEV sans Keycloak | PRODUCTION avec Keycloak |
|---|-------------------|--------------------------|
| Setup | ✅ Immédiat | ⏱️ 10-15 min (install Keycloak) |
| Sécurité | ❌ Aucune | ✅ Rôles + autorisations |
| Performance | ⚡ Rapide (pas de validation JWT) | 🐢 Normale (validation JWK) |
| Tests | ✅ UI, flux métier | ✅ UI, flux métier, sécurité |
| Mobile | ✅ Fonctionne | ✅ Fonctionne |

---

## 🎯 Recommandation

### Pour développer les fonctionnalités métier :
→ **Mode DEV sans Keycloak** (actuel)
- Permet de travailler rapidement
- Pas de dépendance externe
- Tester UI, appels API, flux métier

### Pour tester la sécurité & rôles :
→ **Mode PRODUCTION avec Keycloak**
- Valider les autorisations
- Tester le flow OIDC complet
- Préparer la mise en production

---

**État actuel** : ✅ Mode DEV sans Keycloak activé  
**Prochaine étape** : Redémarrer Dashboard (`npm run dev`)

Si besoin d'aide pour lancer Keycloak plus tard → Consulter `INSTALLATION_KEYCLOAK_COMPLETE.md`









