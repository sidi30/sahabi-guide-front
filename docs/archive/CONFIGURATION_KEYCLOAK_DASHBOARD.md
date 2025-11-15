# ✅ Configuration Keycloak - Dashboard Sahabi Guide

## 🎯 Résumé des modifications

Le dashboard Sahabi Guide a été configuré pour fonctionner en **deux modes** :

### 1️⃣ Mode TEST (par défaut) ⭐
- **Keycloak désactivé**
- Authentification automatique
- Accès Super Admin sans configuration
- Idéal pour le développement et les tests

### 2️⃣ Mode PRODUCTION
- **Keycloak activé**
- Authentification complète via Keycloak
- Gestion des rôles (SUPER_ADMIN, AGENCY_ADMIN)
- Sécurité complète

---

## 📁 Fichiers modifiés/créés

### Fichiers de configuration créés
```
sahabi-guide-dashboard/
├── .env.local                      ✅ Configuration locale (mode TEST par défaut)
├── .env.example                    ✅ Modèle de configuration
├── toggle-keycloak.ps1            ✅ Script PowerShell pour changer de mode
├── toggle-keycloak.sh             ✅ Script Bash pour changer de mode
└── CONFIGURATION_MODE_TEST.md     ✅ Documentation détaillée
```

### Fichiers de code modifiés
```
src/
├── config/api.ts                  ✅ Ajout de ENABLE_KEYCLOAK
├── contexts/AuthContext.tsx       ✅ Logique conditionnelle Keycloak
└── README.md                      ✅ Ajout section démarrage rapide
```

---

## 🚀 Utilisation

### Démarrage rapide (mode TEST)

```bash
cd sahabi-guide-dashboard
npm install
npm run dev
```

✅ **C'est tout !** Le dashboard démarre en mode TEST sans Keycloak.

### Vérifier le mode actuel

**Windows (PowerShell):**
```powershell
.\toggle-keycloak.ps1 status
```

**Linux/Mac (Bash):**
```bash
./toggle-keycloak.sh status
```

### Changer de mode

**Passer en mode PRODUCTION (avec Keycloak):**
```powershell
# Windows
.\toggle-keycloak.ps1 production

# Linux/Mac
./toggle-keycloak.sh production
```

**Revenir en mode TEST (sans Keycloak):**
```powershell
# Windows
.\toggle-keycloak.ps1 test

# Linux/Mac
./toggle-keycloak.sh test
```

⚠️ **Important:** Redémarrez l'application après chaque changement de mode !

---

## 🔍 Configuration actuelle

### Fichier `.env.local` (par défaut)
```env
VITE_ENABLE_KEYCLOAK=false           # Mode TEST activé
VITE_API_BASE_URL=http://localhost:8084
VITE_API_BASE_PATH=/api/v1
VITE_KEYCLOAK_URL=http://localhost:8080
VITE_KEYCLOAK_REALM=sahabi
VITE_KEYCLOAK_CLIENT_ID=sahabi-dashboard
```

### Variable clé
- `VITE_ENABLE_KEYCLOAK=false` → Mode TEST (Keycloak désactivé) ⭐ **PAR DÉFAUT**
- `VITE_ENABLE_KEYCLOAK=true` → Mode PRODUCTION (Keycloak activé)

---

## 💡 Avantages du mode TEST

### Pour le développement
- ✅ **Démarrage immédiat** : Pas besoin de démarrer Keycloak
- ✅ **Configuration zéro** : Pas de paramétrage d'authentification
- ✅ **Accès complet** : Super Admin automatiquement
- ✅ **Tests rapides** : Gain de temps énorme

### Pour les démonstrations
- ✅ **Sans dépendances** : Fonctionne partout
- ✅ **Pas de compte requis** : Pas besoin de créer des utilisateurs
- ✅ **Simplicité** : Une commande suffit

---

## 🔐 Mode PRODUCTION - Prérequis

Si vous souhaitez passer en mode PRODUCTION, assurez-vous que :

1. **Keycloak est installé et démarré**
   ```bash
   # Vérifier que Keycloak répond
   curl http://localhost:8080
   ```

2. **Le realm `sahabi` existe**

3. **Le client `sahabi-dashboard` est configuré**

4. **Les utilisateurs et rôles sont créés**

📖 Documentation complète : `CONFIGURATION_MODE_TEST.md`

---

## 🎨 Comportement par mode

### Mode TEST
```
Console du navigateur :
🔓 Mode TEST activé - Keycloak désactivé
✅ Authentification automatique (Super Admin Test)
```

**Profil utilisateur mocké :**
- Email: `admin@test.com`
- Rôle: `SUPER_ADMIN`
- Nom: `Admin Test`

### Mode PRODUCTION
```
Console du navigateur :
🔐 Initialisation Keycloak...
✅ Keycloak initialisé - Authentifié: true
👤 Token stocké, utilisateur: admin@example.com
```

**Profil depuis Keycloak :**
- Email: Depuis le token
- Rôle: SUPER_ADMIN ou AGENCY_ADMIN
- Nom: Depuis le token

---

## 📊 Tests de validation

### ✅ Vérifier que le mode TEST fonctionne

1. S'assurer que `.env.local` contient `VITE_ENABLE_KEYCLOAK=false`
2. Lancer : `npm run dev`
3. Ouvrir la console du navigateur (F12)
4. Vérifier le log : `🔓 Mode TEST activé`
5. Accéder au dashboard → Pas de redirection vers login

### ✅ Vérifier que le mode PRODUCTION fonctionne

1. Démarrer Keycloak : `docker-compose up keycloak` (si applicable)
2. Modifier `.env.local` : `VITE_ENABLE_KEYCLOAK=true`
3. Lancer : `npm run dev`
4. Ouvrir la console du navigateur (F12)
5. Vérifier le log : `🔐 Initialisation Keycloak`
6. Vérifier la redirection vers Keycloak pour login

---

## 📖 Documentation complète

Pour plus de détails, consultez :
- `sahabi-guide-dashboard/CONFIGURATION_MODE_TEST.md` - Guide complet
- `sahabi-guide-dashboard/README.md` - Démarrage rapide
- `sahabi-guide-dashboard/.env.example` - Exemple de configuration

---

## 🎉 Conclusion

Le dashboard est maintenant configuré en **mode TEST par défaut**, ce qui permet :

✅ **Développement rapide** sans dépendances Keycloak  
✅ **Tests simplifiés** avec authentification automatique  
✅ **Flexibilité** pour passer en mode PRODUCTION quand nécessaire  
✅ **Documentation complète** pour les deux modes  

**Mode actuel : TEST (Keycloak désactivé) 🔓**

Pour passer en mode PRODUCTION, utilisez simplement le script `toggle-keycloak.ps1` ou modifiez `.env.local` !

---

**Date de configuration :** 27 octobre 2025  
**Version :** 1.0 - Configuration initiale mode TEST/PRODUCTION






