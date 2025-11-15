# 🕌 SahabiGuide - Site Web Marketing

[![React](https://img.shields.io/badge/React-18.2-blue.svg)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.2-blue.svg)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-5.0-purple.svg)](https://vitejs.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.4-38bdf8.svg)](https://tailwindcss.com/)
[![Framer Motion](https://img.shields.io/badge/Framer%20Motion-10.16-ff0055.svg)](https://www.framer.com/motion/)

Site web marketing moderne et responsive pour **SahabiGuide**, le compagnon numérique qui accompagne les pèlerins avant, pendant et après le Hadj et la Omra.

## 🎯 À propos du projet

Ce projet est le **site vitrine indépendant** de SahabiGuide, conçu pour :
- Présenter la solution globale (app mobile, assistant IA, bracelet connecté, dashboard)
- Convertir les visiteurs en utilisateurs
- Rassurer les familles et les agences
- Faciliter les partenariats

> **Note :** Ce repository est indépendant des autres projets SahabiGuide (frontend mobile, dashboard, API).

## 🚀 Technologies utilisées

- **React 18** avec **TypeScript**
- **Vite** - Bundler ultra-rapide
- **Tailwind CSS** - Framework CSS utility-first
- **React Router** - Navigation côté client
- **Framer Motion** - Animations fluides et performantes
- **Lucide React** - Icônes modernes

## 📦 Installation

```bash
# Installer les dépendances
npm install

# Lancer le serveur de développement
npm run dev

# Builder pour la production
npm run build

# Prévisualiser le build de production
npm run preview
```

Le site sera accessible sur `http://localhost:3000`

## 📁 Structure du projet

```
sahabi-guide-site/
├── src/
│   ├── assets/          # Images, logos, SVG
│   ├── components/      # Composants réutilisables
│   │   ├── CTAButton.tsx
│   │   ├── Card.tsx
│   │   ├── Header.tsx
│   │   ├── Footer.tsx
│   │   └── SectionTitle.tsx
│   ├── sections/        # Sections de la landing page
│   │   ├── Hero.tsx
│   │   ├── Why.tsx
│   │   ├── ForWho.tsx
│   │   ├── Features.tsx
│   │   ├── AssistantAI.tsx
│   │   ├── Bracelet.tsx
│   │   ├── Agencies.tsx
│   │   ├── DownloadApp.tsx
│   │   ├── Animations.tsx
│   │   ├── Promos.tsx
│   │   ├── FAQ.tsx
│   │   └── Contact.tsx
│   ├── pages/           # Pages de l'application
│   │   └── Home.tsx
│   ├── data/            # Données structurées (FAQ, features, etc.)
│   │   ├── faqs.ts
│   │   ├── features.ts
│   │   └── personas.ts
│   ├── hooks/           # Hooks personnalisés
│   │   └── useScrollToHash.ts
│   ├── App.tsx          # Composant principal
│   ├── main.tsx         # Point d'entrée
│   └── index.css        # Styles globaux
├── public/              # Assets statiques
├── index.html           # Template HTML
├── package.json         # Dépendances
├── tailwind.config.ts   # Configuration Tailwind
├── tsconfig.json        # Configuration TypeScript
└── vite.config.ts       # Configuration Vite
```

## 🎨 Personnalisation

### Couleurs

Les couleurs principales sont définies dans `tailwind.config.ts` :

- **Primary (Vert)** : `primary-50` à `primary-900`
- **Gold (Doré)** : `gold-50` à `gold-900`
- **Navy (Bleu nuit)** : `navy-50` à `navy-900`

Pour modifier la palette, éditez `tailwind.config.ts`.

### Contenus

Les contenus éditables sont centralisés dans le dossier `src/data/` :

- **FAQ** : `src/data/faqs.ts`
- **Fonctionnalités** : `src/data/features.ts`
- **Personas** : `src/data/personas.ts`

### Textes des sections

Les textes principaux sont directement dans les composants de `src/sections/`. 
Recherchez le titre/texte que vous voulez modifier et éditez le fichier correspondant.

### Logo

Remplacez `src/assets/logo.svg` par votre propre logo.

### Liens de téléchargement

Dans `src/sections/DownloadApp.tsx`, remplacez les liens `#` par les vrais liens Google Play / App Store.

## 🔗 Navigation

Le site utilise des ancres pour la navigation :

- `#accueil` - Hero section
- `#fonctionnalites` - Fonctionnalités de l'app
- `#pour-qui` - Section Pour qui ?
- `#assistant` - Assistant IA
- `#bracelet` - Bracelet connecté
- `#agences` - Dashboard agences
- `#telechargement` - Téléchargement app
- `#faq` - Questions fréquentes
- `#contact` - Formulaire de contact

## 🌐 Déploiement

### Netlify / Vercel

1. Connectez votre repository GitHub/GitLab
2. Build command : `npm run build`
3. Output directory : `dist`

### Serveur traditionnel

```bash
npm run build
# Uploadez le contenu du dossier dist/ sur votre serveur
```

## 📱 Responsive

Le site est entièrement responsive et optimisé pour :

- 📱 Mobile (< 640px)
- 📱 Tablette (640px - 1024px)
- 💻 Desktop (> 1024px)

## ⚡ Performance

- Lazy loading des composants
- Animations optimisées avec Framer Motion
- Images optimisées (utilisez WebP pour de meilleures performances)
- Code splitting automatique avec Vite

## 🛠️ Maintenance

### Ajouter une nouvelle section

1. Créez un nouveau composant dans `src/sections/`
2. Importez-le dans `src/pages/Home.tsx`
3. Ajoutez le lien dans le Header (`src/components/Header.tsx`)

### Ajouter une nouvelle FAQ

Éditez `src/data/faqs.ts` et ajoutez un nouvel objet avec `question` et `answer`.

## 📄 License

© 2024 SahabiGuide. Tous droits réservés.

## 🤝 Support

Pour toute question ou assistance :
- Email : contact@sahabiguide.com
- Téléphone : +227 XX XX XX XX

---

**Fait avec ❤️ pour accompagner les pèlerins vers un Hadj serein et connecté**

