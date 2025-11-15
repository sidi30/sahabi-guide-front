# 🔄 Tailscale - Nouvelle Syntaxe (Mise à jour 2025)

La CLI Tailscale Serve a changé. Voici la nouvelle syntaxe.

---

## ✅ Configuration Complète

### Étape 1 : Activer HTTPS sur votre Tailnet

1. Allez sur https://login.tailscale.com/admin/settings/dns
2. Dans la section **"HTTPS Certificates"**, activez **"Enable HTTPS"**
3. Attendez quelques secondes

### Étape 2 : Configurer Tailscale Serve (Nouvelle Syntaxe)

```powershell
# Exposer le frontend sur HTTPS
docker exec sahabi-tailscale tailscale serve --bg http://frontend:80

# Vérifier la configuration
docker exec sahabi-tailscale tailscale serve status
```

Vous devriez voir :

```
https://sahabi-guide.tail2479c5.ts.net/
|-- / proxy http://frontend:80
```

### Étape 3 : (Optionnel) Activer Funnel pour l'accès public

```powershell
# Activer Funnel sur le port 443
docker exec sahabi-tailscale tailscale funnel --bg 443 on

# Vérifier
docker exec sahabi-tailscale tailscale serve status
```

Vous verrez maintenant :

```
https://sahabi-guide.tail2479c5.ts.net/ (Funnel on)
|-- / proxy http://frontend:80
```

---

## 🎯 Comparaison Ancienne vs Nouvelle Syntaxe

### ❌ Ancienne syntaxe (ne fonctionne plus)

```bash
tailscale serve https / http://frontend:80
tailscale funnel 443 on
```

### ✅ Nouvelle syntaxe (à utiliser)

```bash
tailscale serve --bg http://frontend:80
tailscale funnel --bg 443 on
```

**Changements clés :**
- ✅ Ajout du flag `--bg` (background)
- ✅ Plus besoin de spécifier `https /`
- ✅ Syntaxe simplifiée

---

## 📋 Commandes Utiles

### Voir la configuration actuelle

```powershell
docker exec sahabi-tailscale tailscale serve status
```

### Désactiver Serve

```powershell
docker exec sahabi-tailscale tailscale serve off
```

### Désactiver Funnel

```powershell
docker exec sahabi-tailscale tailscale funnel --bg 443 off
```

### Voir l'aide

```powershell
docker exec sahabi-tailscale tailscale serve --help
docker exec sahabi-tailscale tailscale funnel --help
```

---

## 🚀 Script Automatique Mis à Jour

Utilisez le script mis à jour :

```powershell
.\scripts\deployment\setup-tailscale-funnel.ps1
```

Ce script utilise maintenant la nouvelle syntaxe.

---

## 🌐 Configuration Avancée : Plusieurs Services

### Exposer plusieurs services sur différents chemins

```powershell
# Frontend sur /
docker exec sahabi-tailscale tailscale serve --bg http://frontend:80

# Backend API sur le port 8084
docker exec sahabi-tailscale tailscale serve --bg --set-path /api http://backend:8084

# Keycloak sur le port 8080
docker exec sahabi-tailscale tailscale serve --bg --set-path /auth http://keycloak:8080

# Vérifier
docker exec sahabi-tailscale tailscale serve status
```

---

## 📖 Documentation Officielle

Pour plus d'informations, consultez :
https://tailscale.com/kb/1242/tailscale-serve

---

## ✅ Résumé Rapide

**Ce que vous devez faire maintenant :**

1. **Activer HTTPS** sur https://login.tailscale.com/admin/settings/dns

2. **Configurer Serve** avec la nouvelle syntaxe :
   ```powershell
   docker exec sahabi-tailscale tailscale serve --bg http://frontend:80
   ```

3. **(Optionnel) Activer Funnel** pour l'accès public :
   ```powershell
   docker exec sahabi-tailscale tailscale funnel --bg 443 on
   ```

4. **Vérifier** :
   ```powershell
   docker exec sahabi-tailscale tailscale serve status
   ```

5. **Accéder** à votre application via l'URL affichée (ex: `https://sahabi-guide.tail2479c5.ts.net`)

---

**Dernière mise à jour** : 2025-11-08  
**Version Tailscale** : v1.90.6+

