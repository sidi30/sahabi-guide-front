# 📚 Documentation Sahabi Guide

Bienvenue dans la documentation complète du projet Sahabi Guide.

## 📁 Structure de la documentation

```
docs/
├── architecture/        # Architecture technique et intégrations
├── deployment/          # Guides de déploiement
├── guides/              # Guides d'utilisation et de configuration
├── audits/              # Rapports d'audit et analyses
└── archive/             # Documentation archivée
```

## 🚀 Démarrage rapide

Pour commencer rapidement avec le projet :

1. **Installation locale** : Consultez [`guides/quick-start.md`](./guides/quick-start.md)
2. **Configuration Keycloak** : Voir [`guides/keycloak-setup.md`](./guides/keycloak-setup.md)
3. **Déploiement Docker** : Voir [`deployment/docker.md`](./deployment/docker.md)

## 🏗 Architecture

### Intégrations principales

- **[Intégration Airalo (eSIM)](./architecture/AIRALO_INTEGRATION_GUIDE.md)** - Guide complet d'intégration de l'API Airalo pour l'achat de forfaits eSIM
- **[Résumé Airalo (FR)](./architecture/AIRALO_INTEGRATION_RESUME_FR.md)** - Version française condensée

### Authentification

Consultez les documents dans [`audits/`](./audits/) pour comprendre :
- Le système d'authentification sans Keycloak (JWT uniquement)
- L'harmonisation des profils utilisateurs
- Les analyses de connexion

## 📦 Déploiement

### Environnements disponibles

- **Local** : Développement avec Docker Compose
- **Production** : Déploiement avec Docker
- **Cloud** : Railway, Heroku, AWS, etc.

### Guides de déploiement

- [Docker](./deployment/docker.md)
- [Railway](./deployment/railway.md)
- [Tailscale (VPN)](./deployment/TAILSCALE_PRET.md)
- [Production](./guides/GUIDE_MISE_EN_PRODUCTION.md)

## 🔍 Audits et analyses

Le dossier [`audits/`](./audits/) contient tous les rapports d'audit :

- Analyses de sécurité
- Audits de code
- Optimisations de performance
- Analyses de base de données
- Rapports de refactoring

## 📝 Contribuer à la documentation

Pour ajouter ou modifier la documentation :

1. Créez un fichier Markdown (`.md`) dans le bon dossier
2. Suivez les conventions de nommage :
   - Utilisez des majuscules et underscores : `NOM_FICHIER.md`
   - Soyez descriptif et précis
3. Utilisez les en-têtes Markdown pour structurer le contenu
4. Ajoutez des liens vers d'autres documents pertinents
5. Mettez à jour ce README si nécessaire

## 🗂 Conventions de documentation

### En-têtes

```markdown
# Titre principal (H1) - Un seul par document
## Section principale (H2)
### Sous-section (H3)
#### Détails (H4)
```

### Code

Utilisez des blocs de code avec le langage approprié :

```java
// Java
@Service
public class MyService {
    // ...
}
```

```typescript
// TypeScript
export const myFunction = () => {
    // ...
}
```

### Liens

- **Relatifs** pour les liens internes : `[Texte](./chemin/vers/fichier.md)`
- **Absolus** pour les liens externes : `[Texte](https://example.com)`

### Images

Placez les images dans un dossier `images/` au même niveau que le document :

```markdown
![Description](./images/mon-image.png)
```

## 📞 Questions ?

Si vous ne trouvez pas l'information recherchée :

1. Vérifiez d'abord les README spécifiques de chaque module :
   - [Backend API](../sahabi-guide-api/README.md)
   - [Dashboard React](../sahabi-guide-dashboard/README.md)
   - [App Flutter](../sahabi-guide-front/README.md)

2. Consultez les audits pour les analyses détaillées

3. Contactez l'équipe de développement

---

*Dernière mise à jour : Novembre 2025*


