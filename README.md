# SahabiGuide – Landing page (React + Vite + TS + Tailwind)

Un site marketing moderne, responsive et animé pour présenter la solution SahabiGuide : application mobile, assistant IA, bracelet connecté (SahabiBand) et dashboard pour agences.

## Démarrage

1) Installer les dépendances

```bash
npm install
```

2) Lancer le serveur de dev

```bash
npm run dev
```

3) Build de production

```bash
npm run build
npm run preview
```

## Stack

- React 18 + TypeScript
- Vite 5
- Tailwind CSS 3
- React Router (navigation SPA)
- Framer Motion (animations)
- lucide-react (icônes)

## Structure

```
.
├─ src/
│  ├─ assets/              # images, logos
│  ├─ components/          # composants réutilisables (Header, Footer, CTA, etc.)
│  ├─ data/                # contenus structurés (FAQ, features, personas)
│  ├─ hooks/               # hooks utilitaires (useScrollToHash)
│  ├─ pages/               # pages (Home)
│  ├─ sections/            # sections de la landing
│  ├─ App.tsx              # layout global
│  ├─ index.css            # styles globaux (Tailwind layers)
│  └─ main.tsx             # bootstrap React + Router
├─ index.html              # fonts, meta, point d'entrée
├─ tailwind.config.ts      # palette, extensions
├─ postcss.config.js
├─ vite.config.ts
├─ tsconfig.json
└─ package.json
```

## Contenu modifiable facilement

- Textes / listes: `src/data/` (`faqs.ts`, `features.ts`, `personas.ts`)
- Titres / sous-titres: dans chaque fichier de `src/sections/`
- Couleurs: `tailwind.config.ts` (palette `brand`, `gold`, `night`, `sand`)
- Polices: `index.html` (Google Fonts)
- Icônes: `lucide-react` (remplacez les icônes dans les sections)
- Logo: `src/assets/logo.svg`

## Ancrages de navigation

Le header propose des liens d’ancrage vers:
`#accueil`, `#fonctionnalites`, `#pour-qui`, `#assistant`, `#bracelet`, `#agences`, `#telechargement`, `#faq`, `#contact`.

Le hook `useScrollToHash` assure un scroll doux lors d’un changement de hash.

## Accessibilité & UX

- Boutons et liens avec `focus` visibles
- Accordéon FAQ accessible au clavier
- Contrastes lisibles et mise en page épurée

## Personnalisation

- Palette: modifiez `tailwind.config.ts`
- Sections: éditez les composants dans `src/sections/`
- CTAs: `src/components/CTAButton.tsx`
- Cartes: `src/components/Card.tsx`
- Titres: `src/components/SectionTitle.tsx`

## Objectif

Informer, inspirer confiance et inciter au téléchargement de l’application, avec une présentation claire des bénéfices pour pèlerins, familles, agences et autorités.

# 🕋 Sahabi Guide - Système de gestion de pèlerinage

> Plateforme complète pour la gestion et l'accompagnement des pèlerins du Hajj et de la Omra

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![React](https://img.shields.io/badge/React-18-blue.svg)](https://reactjs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-Latest-02569B.svg)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791.svg)](https://www.postgresql.org/)

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Fonctionnalités](#-fonctionnalités)
- [Technologies](#-technologies)
- [Installation](#-installation)
- [Documentation](#-documentation)
- [Contribution](#-contribution)
- [License](#-license)

## 🎯 Vue d'ensemble

Sahabi Guide est une solution complète qui aide les agences de voyage et les pèlerins à gérer tous les aspects du Hajj et de la Omra :

- **Suivi GPS en temps réel** des pèlerins
- **Gestion de groupes** et d'agences
- **Guides des rituels** étape par étape
- **Alertes et notifications** importantes
- **Gestion de la santé** des pèlerins
- **Achat de forfaits eSIM** (via Airalo)
- **Dashboard administratif** complet
- **Application mobile** pour les pèlerins

## 🏗 Architecture

Le projet est composé de 3 applications principales :

```
sahabiGuide/
├── sahabi-guide-api/          # 🚀 Backend Spring Boot (API REST)
├── sahabi-guide-dashboard/    # 💻 Dashboard React (Admin)
├── sahabi-guide-front/        # 📱 Application mobile Flutter
└── third-party/               # 🔌 Services externes (Traccar)
```

### Stack technique

**Backend** :
- Java 21 + Spring Boot 3.5.4
- PostgreSQL 15
- Liquibase (migrations)
- Keycloak (authentification)
- JWT (mobile auth)

**Dashboard** :
- React 18 + TypeScript
- Vite
- Tailwind CSS
- Keycloak adapter

**Mobile** :
- Flutter (Android + iOS)
- JWT authentication
- Google Maps / OpenStreetMap

## ✨ Fonctionnalités

### 👥 Pour les Administrateurs (Dashboard)

- ✅ Gestion des agences et utilisateurs
- ✅ Suivi des pèlerins en temps réel sur carte
- ✅ Création de groupes et affectation
- ✅ Gestion des POIs (Points d'intérêt)
- ✅ Envoi d'alertes et messages
- ✅ Statistiques et rapports
- ✅ Gestion des forfaits de connectivité

### 📱 Pour les Pèlerins (App Mobile)

- ✅ Authentification par passeport + OTP (SMS)
- ✅ Guides des rituels (Hajj & Omra)
- ✅ Dou'as contextuelles
- ✅ Partage de position GPS
- ✅ Réception d'alertes importantes
- ✅ Profil de santé et contacts d'urgence
- ✅ Achat de forfaits eSIM en 1 clic
- ✅ Suivi de consommation data

### 🌐 Fonctionnalités avancées

- ✅ **Géolocalisation temps réel** avec Traccar
- ✅ **Géofencing** (alertes de sortie de zone)
- ✅ **Partage de localisation** via lien public
- ✅ **Intégration Airalo** pour eSIM
- ✅ **Vérification compatibilité eSIM** des appareils
- ✅ **Multi-langues** (FR, AR, EN)
- ✅ **Mode hors-ligne** (rituels et dou'as)

## 🛠 Technologies

| Catégorie | Technologies |
|-----------|-------------|
| **Backend** | Spring Boot, Spring Security, Spring Data JPA, Spring Retry |
| **Database** | PostgreSQL, Liquibase, Hibernate |
| **Auth** | Keycloak (OAuth2/OIDC), JWT |
| **Frontend** | React, TypeScript, Vite, Tailwind CSS |
| **Mobile** | Flutter, Dart |
| **APIs externes** | Twilio (SMS), Airalo (eSIM), Traccar (GPS) |
| **DevOps** | Docker, Docker Compose, Railway |
| **Monitoring** | Actuator, Prometheus-ready |

## 🚀 Installation

### Prérequis

- Java 21+
- Node.js 18+
- Flutter SDK
- Docker & Docker Compose
- PostgreSQL 15 (ou via Docker)

### Installation rapide (Docker)

```bash
# Cloner le projet
git clone https://github.com/votre-org/sahabiGuide.git
cd sahabiGuide

# Copier et configurer les variables d'environnement
cp env.template .env
# Éditer .env avec vos valeurs

# Démarrer tous les services
docker-compose up -d

# Les services seront disponibles sur :
# - API Backend : http://localhost:8080
# - Dashboard : http://localhost:3000
# - Keycloak : http://localhost:8090
# - PostgreSQL : localhost:5432
```

### Installation manuelle

Consultez les README spécifiques de chaque module :

- [Backend API](./sahabi-guide-api/README.md)
- [Dashboard React](./sahabi-guide-dashboard/README.md)
- [App Flutter](./sahabi-guide-front/README.md)

## 📚 Documentation

Toute la documentation est organisée dans le dossier [`docs/`](./docs/) :

### Guides de démarrage

- [Guide de démarrage rapide](./docs/guides/quick-start.md)
- [Configuration Keycloak](./docs/guides/keycloak-setup.md)
- [Guide de déploiement](./docs/deployment/docker.md)

### Architecture

- [Intégration Airalo eSIM](./docs/architecture/AIRALO_INTEGRATION_GUIDE.md)
- [Système d'authentification](./docs/audits/ANALYSE_CONNEXION_SANS_KEYCLOAK.md)
- [Schéma de base de données](./docs/architecture/database-schema.md)

### Déploiement

- [Déploiement Docker](./docs/deployment/docker.md)
- [Déploiement sur Railway](./docs/deployment/railway.md)
- [Configuration Tailscale](./docs/deployment/TAILSCALE_PRET.md)

## 🔧 Configuration

### Variables d'environnement principales

Créez un fichier `.env` à la racine du projet :

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sahabi_db
DB_USERNAME=sahabi
DB_PASSWORD=votre_mot_de_passe

# Keycloak
OIDC_ISSUER_URI=http://localhost:8090/realms/sahabi

# JWT (mobile)
JWT_SECRET=votre_secret_jwt_long_et_securise

# Twilio (SMS/OTP)
TWILIO_ACCOUNT_SID=votre_account_sid
TWILIO_AUTH_TOKEN=votre_auth_token
TWILIO_PHONE_NUMBER=+33612345678

# Airalo (eSIM)
AIRALO_ENABLED=true
AIRALO_CLIENT_ID=votre_client_id
AIRALO_CLIENT_SECRET=votre_client_secret
AIRALO_BASE_URL=https://partners-api.airalo.com

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
```

Voir [`env.template`](./env.template) pour toutes les variables disponibles.

## 🧪 Tests

```bash
# Backend
cd sahabi-guide-api
mvn test

# Dashboard
cd sahabi-guide-dashboard
npm test

# Flutter
cd sahabi-guide-front
flutter test
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 License

Ce projet est sous licence propriétaire. Tous droits réservés.

## 👥 Équipe

- **Backend Lead** : [Nom]
- **Frontend Lead** : [Nom]
- **Mobile Lead** : [Nom]
- **DevOps** : [Nom]

## 📞 Support

Pour toute question ou problème :

- 📧 Email : support@sahabi-guide.com
- 📱 WhatsApp : +XXX XXX XXX XXX
- 🐛 Issues : [GitHub Issues](https://github.com/votre-org/sahabiGuide/issues)

---

<div align="center">

**Fait avec ❤️ pour faciliter le pèlerinage des musulmans**

*"Et accomplissez le Hajj et la 'Omra pour Allah" - Sourate Al-Baqarah (2:196)*

</div>
