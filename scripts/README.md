# 📜 Scripts Sahabi Guide

Ce dossier contient tous les scripts d'automatisation du projet.

---

## 📁 Structure

```
scripts/
├── deployment/     # Déploiement et accès Internet
├── docker/         # Gestion des conteneurs Docker
├── database/       # Sauvegarde et restauration DB
└── utils/          # Scripts utilitaires
```

---

## 🚀 deployment/ - Déploiement

Scripts pour rendre l'application accessible depuis Internet.

### Windows (PowerShell)

#### Déploiement avec Tailscale
```powershell
.\deployment\deploy-internet.ps1 -Mode tailscale -TailscaleKey "tskey-auth-..."
```

#### Déploiement avec Caddy + Domaine
```powershell
.\deployment\deploy-internet.ps1 -Mode caddy -Domain "monsite.com" -Email "email@example.com"
```

#### Correction Tailscale
```powershell
.\deployment\fix-tailscale.ps1
```

#### Configuration Funnel (accès public)
```powershell
.\deployment\setup-tailscale-funnel.ps1
```

### Linux/Mac (Bash)

```bash
# Tailscale
./deployment/deploy-internet.sh tailscale --key "tskey-auth-..."

# Caddy + Domaine
./deployment/deploy-internet.sh caddy --domain "monsite.com" --email "email@example.com"
```

📖 **Documentation** : [docs/deployment/INTERNET_ACCESS.md](../docs/deployment/INTERNET_ACCESS.md)

---

## 🐳 docker/ - Gestion Docker

Scripts pour démarrer et arrêter les services.

### Démarrer tous les services

**Windows :**
```powershell
.\docker\start.ps1
```

**Linux/Mac :**
```bash
./docker/start.sh
```

### Arrêter tous les services

```bash
./docker/stop.sh
```

---

## 💾 database/ - Base de données

Scripts pour sauvegarder et restaurer PostgreSQL.

### Créer une sauvegarde

```bash
./database/backup.sh
```

Crée un fichier `backup_YYYYMMDD_HHMMSS.sql` dans le répertoire courant.

### Restaurer une sauvegarde

```bash
./database/restore.sh backup_20250108_120000.sql
```

⚠️ **Attention** : La restauration écrase toutes les données existantes !

---

## 🛠️ utils/ - Utilitaires

Scripts utilitaires divers.

### Voir les logs en temps réel

```bash
./utils/logs.sh
```

### Configurer les permissions (Linux uniquement)

```bash
./utils/setup-permissions.sh
```

---

## 📝 Notes

### Permissions sous Linux/Mac

Rendez les scripts exécutables :

```bash
chmod +x deployment/*.sh
chmod +x docker/*.sh
chmod +x database/*.sh
chmod +x utils/*.sh
```

### Exécution sous Windows

Si vous avez des erreurs d'exécution :

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🔗 Liens utiles

- [Documentation principale](../README.md)
- [Guide de déploiement](../docs/deployment/README.md)
- [Accès Internet](../docs/deployment/INTERNET_ACCESS.md)

