# Guide de Test - Améliorations Mobile Flutter

## 🧪 Checklist de Tests

### ✅ 1. Test du Splash Screen

#### Test 1.1 : Premier Lancement
- [ ] Désinstaller l'application complètement
- [ ] Réinstaller l'application
- [ ] Lancer l'application
- [ ] **Vérifier** : Animation splash s'affiche (logo + effets)
- [ ] **Vérifier** : Durée ~2.5 secondes
- [ ] **Vérifier** : Redirection vers page de choix Pèlerin/Visiteur

#### Test 1.2 : Lancements Suivants
- [ ] Fermer l'application
- [ ] Relancer l'application
- [ ] **Vérifier** : Pas de splash (redirection directe)
- [ ] **Vérifier** : Navigation fluide et rapide

#### Test 1.3 : Animation
- [ ] Observer l'animation du logo
- [ ] **Vérifier** : Effet de fade-in
- [ ] **Vérifier** : Effet de scale
- [ ] **Vérifier** : Pulsation du logo
- [ ] **Vérifier** : Effet glow rotatif
- [ ] **Vérifier** : Points de chargement animés

---

### ✅ 2. Test du Choix Pèlerin/Visiteur

#### Test 2.1 : Interface
- [ ] Accéder à la page de choix
- [ ] **Vérifier** : Logo SahabiGuide visible
- [ ] **Vérifier** : Deux options : "Pèlerin" et "Visiteur"
- [ ] **Vérifier** : Sous-titres : "Avec passeport" et "Juste explorer"
- [ ] **Vérifier** : Icônes appropriées
- [ ] **Vérifier** : Sélection de langue (Hausa/Djerma)

#### Test 2.2 : Sélection Pèlerin
- [ ] Sélectionner "Pèlerin"
- [ ] Choisir une langue
- [ ] Cliquer sur "Continuer"
- [ ] **Vérifier** : Redirection vers page de connexion passeport
- [ ] **Vérifier** : Champs de saisie passeport visible

#### Test 2.3 : Sélection Visiteur
- [ ] Revenir à la page de choix
- [ ] Sélectionner "Visiteur"
- [ ] Choisir une langue
- [ ] Cliquer sur "Continuer"
- [ ] **Vérifier** : Redirection vers page d'inscription newsletter

#### Test 2.4 : Continuer Sans Connexion
- [ ] Revenir à la page de choix
- [ ] Cliquer sur "Continuer sans connexion"
- [ ] **Vérifier** : Redirection directe vers page d'accueil
- [ ] **Vérifier** : Mode visiteur activé

---

### ✅ 3. Test de l'Inscription Visiteur

#### Test 3.1 : Interface
- [ ] Accéder à la page d'inscription visiteur
- [ ] **Vérifier** : Icône d'exploration visible
- [ ] **Vérifier** : Titre "Explorez SahabiGuide"
- [ ] **Vérifier** : Trois champs : Nom, Email, Téléphone
- [ ] **Vérifier** : Case à cocher pour newsletter
- [ ] **Vérifier** : Bouton "S'inscrire et continuer"
- [ ] **Vérifier** : Lien "Continuer sans inscription"
- [ ] **Vérifier** : Info box sur la sécurité

#### Test 3.2 : Validation Nom
- [ ] Laisser le champ vide → Cliquer "S'inscrire"
- [ ] **Vérifier** : Message "Nom requis"
- [ ] Entrer "Ab" (2 caractères) → Cliquer "S'inscrire"
- [ ] **Vérifier** : Message "au moins 3 caractères"
- [ ] Entrer "Ahmed Moussa" → Valider
- [ ] **Vérifier** : Pas d'erreur

#### Test 3.3 : Validation Email
- [ ] Laisser le champ vide → Cliquer "S'inscrire"
- [ ] **Vérifier** : Message "Email requis"
- [ ] Entrer "test@" → Cliquer "S'inscrire"
- [ ] **Vérifier** : Message "Email invalide"
- [ ] Entrer "test@example.com" → Valider
- [ ] **Vérifier** : Pas d'erreur

#### Test 3.4 : Validation Téléphone
- [ ] Laisser le champ vide → Cliquer "S'inscrire"
- [ ] **Vérifier** : Message "Téléphone requis"
- [ ] Entrer "123" → Cliquer "S'inscrire"
- [ ] **Vérifier** : Message "Numéro invalide"
- [ ] Entrer "+227 90 12 34 56" → Valider
- [ ] **Vérifier** : Pas d'erreur

#### Test 3.5 : Case à Cocher
- [ ] Remplir tous les champs correctement
- [ ] Ne PAS cocher la case
- [ ] Cliquer "S'inscrire"
- [ ] **Vérifier** : Message "accepter les conditions"
- [ ] Cocher la case → Cliquer "S'inscrire"
- [ ] **Vérifier** : Inscription réussie

#### Test 3.6 : Inscription Réussie
- [ ] Remplir le formulaire complètement
- [ ] Cocher la case
- [ ] Cliquer "S'inscrire et continuer"
- [ ] **Vérifier** : Message de succès
- [ ] **Vérifier** : Redirection vers page d'accueil
- [ ] **Vérifier** : Mode visiteur activé

#### Test 3.7 : Continuer Sans Inscription
- [ ] Accéder à la page d'inscription
- [ ] Cliquer "Continuer sans inscription"
- [ ] **Vérifier** : Redirection immédiate vers page d'accueil
- [ ] **Vérifier** : Pas de données sauvegardées

---

### ✅ 4. Test de l'Accès au Contenu

#### Test 4.1 : Page d'Accueil (Visiteur)
- [ ] Se connecter en tant que visiteur
- [ ] Accéder à la page d'accueil
- [ ] **Vérifier** : Message "Bienvenue sur SahabiGuide"
- [ ] **Vérifier** : Bouton "Se connecter" visible
- [ ] **Vérifier** : Heures de prière affichées
- [ ] **Vérifier** : Statistiques visibles
- [ ] **Vérifier** : Menu des fonctionnalités accessible

#### Test 4.2 : Page d'Accueil (Pèlerin)
- [ ] Se connecter en tant que pèlerin
- [ ] Accéder à la page d'accueil
- [ ] **Vérifier** : Message personnalisé avec prénom
- [ ] **Vérifier** : "Bonjour, [Prénom]"
- [ ] **Vérifier** : Icône de profil visible
- [ ] **Vérifier** : Contenu identique au visiteur

#### Test 4.3 : Rituels (Accessible)
- [ ] En mode visiteur
- [ ] Naviguer vers "Rituels"
- [ ] **Vérifier** : Accès autorisé
- [ ] **Vérifier** : Liste des rituels visible
- [ ] Cliquer sur un rituel
- [ ] **Vérifier** : Détails accessibles

#### Test 4.4 : Duas (Accessible)
- [ ] En mode visiteur
- [ ] Naviguer vers "Duas"
- [ ] **Vérifier** : Accès autorisé
- [ ] **Vérifier** : Liste des duas visible
- [ ] **Vérifier** : Lecture possible

#### Test 4.5 : Vidéos (Accessible)
- [ ] En mode visiteur
- [ ] Naviguer vers "Vidéos"
- [ ] **Vérifier** : Accès autorisé
- [ ] **Vérifier** : Liste des vidéos visible

#### Test 4.6 : Bot (Accessible)
- [ ] En mode visiteur
- [ ] Naviguer vers "Bot"
- [ ] **Vérifier** : Accès autorisé
- [ ] **Vérifier** : Chat fonctionnel

#### Test 4.7 : Profil (Protégé)
- [ ] En mode visiteur
- [ ] Tenter d'accéder au profil
- [ ] **Vérifier** : Redirection vers connexion
- [ ] **Vérifier** : Message approprié

#### Test 4.8 : Carte (Protégé)
- [ ] En mode visiteur
- [ ] Tenter d'accéder à la carte
- [ ] **Vérifier** : Redirection vers connexion
- [ ] **Vérifier** : Message approprié

#### Test 4.9 : Santé (Protégé)
- [ ] En mode visiteur
- [ ] Tenter d'accéder à la santé
- [ ] **Vérifier** : Redirection vers connexion
- [ ] **Vérifier** : Message approprié

---

### ✅ 5. Test de Navigation

#### Test 5.1 : Bottom Navigation
- [ ] Accéder à la page d'accueil
- [ ] **Vérifier** : Barre de navigation visible en bas
- [ ] Cliquer sur chaque onglet
- [ ] **Vérifier** : Navigation fluide
- [ ] **Vérifier** : Pas de rechargement inutile

#### Test 5.2 : Bouton Retour
- [ ] Naviguer dans plusieurs pages
- [ ] Utiliser le bouton retour
- [ ] **Vérifier** : Navigation cohérente
- [ ] **Vérifier** : Pas de boucles

#### Test 5.3 : Deep Links
- [ ] Tester les liens directs vers pages
- [ ] **Vérifier** : Redirection correcte
- [ ] **Vérifier** : Gestion de l'authentification

---

### ✅ 6. Test de Performance

#### Test 6.1 : Temps de Démarrage
- [ ] Fermer l'application
- [ ] Chronométrer le lancement
- [ ] **Vérifier** : < 3 secondes (premier lancement)
- [ ] **Vérifier** : < 1 seconde (lancements suivants)

#### Test 6.2 : Fluidité des Animations
- [ ] Observer toutes les animations
- [ ] **Vérifier** : Pas de saccades
- [ ] **Vérifier** : 60 FPS constant

#### Test 6.3 : Consommation Mémoire
- [ ] Utiliser l'app pendant 5 minutes
- [ ] Naviguer dans toutes les sections
- [ ] **Vérifier** : Pas de fuites mémoire
- [ ] **Vérifier** : App réactive

---

### ✅ 7. Test de Persistance

#### Test 7.1 : Données Visiteur
- [ ] S'inscrire en tant que visiteur
- [ ] Fermer l'application
- [ ] Rouvrir l'application
- [ ] **Vérifier** : Statut visiteur conservé
- [ ] **Vérifier** : Pas de re-demande d'inscription

#### Test 7.2 : Préférences
- [ ] Choisir une langue
- [ ] Fermer l'application
- [ ] Rouvrir l'application
- [ ] **Vérifier** : Langue conservée

#### Test 7.3 : État de Connexion
- [ ] Se connecter en tant que pèlerin
- [ ] Fermer l'application
- [ ] Rouvrir l'application
- [ ] **Vérifier** : Toujours connecté
- [ ] **Vérifier** : Accès direct à l'accueil

---

### ✅ 8. Test de Déconnexion

#### Test 8.1 : Déconnexion Pèlerin
- [ ] Se connecter en tant que pèlerin
- [ ] Accéder au profil
- [ ] Cliquer sur "Déconnexion"
- [ ] **Vérifier** : Redirection vers page de choix
- [ ] **Vérifier** : Données effacées

#### Test 8.2 : Retour en Mode Visiteur
- [ ] Après déconnexion
- [ ] Choisir "Visiteur"
- [ ] **Vérifier** : Accès en mode visiteur
- [ ] **Vérifier** : Fonctionnalités limitées

---

### ✅ 9. Test des Cas Limites

#### Test 9.1 : Pas de Connexion Internet
- [ ] Désactiver le WiFi et les données
- [ ] Lancer l'application
- [ ] **Vérifier** : Splash fonctionne
- [ ] **Vérifier** : Message d'erreur approprié
- [ ] **Vérifier** : Pas de crash

#### Test 9.2 : Connexion Lente
- [ ] Simuler une connexion 2G
- [ ] Utiliser l'application
- [ ] **Vérifier** : Indicateurs de chargement
- [ ] **Vérifier** : Pas de timeout brutal

#### Test 9.3 : Données Corrompues
- [ ] Modifier manuellement SharedPreferences
- [ ] Lancer l'application
- [ ] **Vérifier** : Gestion d'erreur gracieuse
- [ ] **Vérifier** : Réinitialisation si nécessaire

---

## 📱 Appareils de Test Recommandés

### Android
- [ ] **Émulateur** : Pixel 5 (Android 12)
- [ ] **Réel** : Samsung Galaxy (Android 11+)
- [ ] **Réel** : Xiaomi/Huawei (Android 10+)

### iOS
- [ ] **Simulateur** : iPhone 13 (iOS 15+)
- [ ] **Réel** : iPhone 11+ (iOS 14+)

---

## 🐛 Bugs Connus à Vérifier

- [ ] Aucun bug connu actuellement
- [ ] Tous les linters passent
- [ ] Compilation réussie

---

## ✅ Validation Finale

### Checklist Globale
- [ ] Tous les tests passent
- [ ] Aucune erreur de linting
- [ ] Performance satisfaisante
- [ ] UX fluide et intuitive
- [ ] Pas de crash
- [ ] Documentation à jour

### Prêt pour Production ?
- [ ] ✅ OUI - Tous les tests passent
- [ ] ❌ NON - Problèmes à résoudre : _________________

---

**Date de test** : _______________  
**Testeur** : _______________  
**Version testée** : 2.0.0  
**Résultat global** : ⬜ PASS / ⬜ FAIL
