# 🧪 Guide de Test - Bot Hajj Phase 1

## 🎯 Objectif
Tester les 3 nouvelles fonctionnalités implémentées :
1. ✅ Navigation corrigée (OUI/NON)
2. ✅ Bouton flottant animé
3. ✅ Indicateur de progression

---

## 📝 Prérequis

### 1. Base de Données
- PostgreSQL en cours d'exécution
- Base de données `sahabi_guide` accessible
- pgAdmin ou DBeaver installé

### 2. Backend Spring Boot
- Backend démarré sur `http://localhost:8084`
- Vérifier les logs : `[sahabi] [...] Started SahabiApplication`

### 3. Frontend Flutter
- Chrome ou émulateur Android démarré
- Terminal dans `sahabi-guide-front/`

---

## 🔧 Étape 1 : Mettre à Jour la Base de Données

### 1.1. Ouvrir le Script SQL
```bash
# Fichier : SEED_ASSISTANT_FIXED.sql
# Emplacement : racine du projet
```

### 1.2. Exécuter dans pgAdmin/DBeaver

**Méthode 1 - pgAdmin** :
1. Ouvrir pgAdmin
2. Se connecter à `sahabi_guide`
3. Clic droit → Query Tool
4. Ouvrir `SEED_ASSISTANT_FIXED.sql`
5. Cliquer sur Execute (F5)
6. Vérifier le résultat :
   ```
   DELETE 28
   INSERT 0 28
   Nombre d'étapes: 28
   ```

**Méthode 2 - Terminal** :
```bash
psql -U postgres -d sahabi_guide -f SEED_ASSISTANT_FIXED.sql
```

**Méthode 3 - DBeaver** :
1. Ouvrir DBeaver
2. Se connecter à `sahabi_guide`
3. Nouvelle requête SQL
4. Coller le contenu de `SEED_ASSISTANT_FIXED.sql`
5. Exécuter (Ctrl+Enter)

### 1.3. Vérifier les Données
```sql
-- Compter les étapes
SELECT COUNT(*) FROM conversation_steps;
-- Résultat attendu : 28

-- Voir la première étape
SELECT step_code, question, navigation_rules_json 
FROM conversation_steps 
WHERE step_code = 'HAJJ_INTRO';

-- Résultat attendu :
-- navigation_rules_json: {"OUI": "HAJJ_PREPARATION", "NON": "HAJJ_MOTIVATION"}
```

✅ **Validation** : 28 étapes présentes avec clés en MAJUSCULES

---

## 🚀 Étape 2 : Redémarrer l'Application Flutter

### 2.1. Hot Restart
```bash
# Dans le terminal où Flutter tourne
# Appuyer sur : R

# Attendre le message :
# Restarted application in XXXms.
```

### 2.2. Ou Full Restart
```bash
# Arrêter (q)
# Relancer :
cd sahabi-guide-front
flutter run -d chrome
```

---

## 🧪 Test 1 : Bouton Flottant Animé

### 🎬 Scénario
1. Ouvrir l'app dans Chrome : `http://localhost:XXXX`
2. Aller sur la page **Accueil** (🏠)

### ✅ Points à Vérifier
- [ ] Bouton visible en **bas à droite**
- [ ] Icône : 🤖 + texte "Assistant"
- [ ] **Animation visible** :
  - [ ] Rotation lente (6 secondes par tour)
  - [ ] Effet "respiration" (grossit/rétré cit)
  - [ ] Halo lumineux autour
- [ ] Couleur : Bleu (#1D3557) ou Vert (#06D6A0)

### 🎬 Interaction
1. **Cliquer** sur le bouton flottant
2. **Résultat attendu** : Navigation vers `/assistant`
3. **Sur la page assistant** : Le bouton flottant **disparaît** ✅

### 🎬 Navigation Entre Pages
1. Aller sur **Rituels** (📿)
   - [ ] Bouton flottant visible
2. Aller sur **Carte** (🗺️)
   - [ ] Bouton flottant visible
3. Aller sur **Santé** (❤️)
   - [ ] Bouton flottant visible
4. Cliquer sur le bouton → **toujours** ouvre `/assistant`

### 📸 Capture d'Écran Attendue
```
┌─────────────────────────────────┐
│  🏠 Sahabi Guide           ⚙️   │
├─────────────────────────────────┤
│                                 │
│  🕋 Rituels du Hajj             │
│  📿 Douas & Invocations         │
│  🗺️ Carte Interactive           │
│                                 │
│                                 │
│                                 │
│                       ┌────────┐│ ← Bouton animé
│                       │ 🤖     ││
│                       │Assistant││
│                       └────────┘│
│                                 │
├─────────────────────────────────┤
│ [🏠] [📅] [🗺️] [🎥] [👤]      │
└─────────────────────────────────┘
```

✅ **Test Réussi** : Bouton visible, animé, et fonctionnel

---

## 🧪 Test 2 : Indicateur de Progression

### 🎬 Scénario
1. Cliquer sur le bouton flottant (ou aller sur `/assistant`)
2. Observer l'interface

### ✅ Points à Vérifier - AppBar

**Barre de Progression** (sous l'AppBar) :
- [ ] Ligne bleue de **4px** de hauteur
- [ ] Largeur : 100% de l'écran
- [ ] Progression : **0%** au début (ligne vide)

### ✅ Points à Vérifier - Badge

**Badge en Haut du Chat** :
- [ ] Fond bleu clair (`Colors.blue[50]`)
- [ ] Icône 📊 (analytics)
- [ ] Texte : **"0 / 28 étapes complétées (0%)"**
- [ ] Couleur texte : Bleu foncé
- [ ] Bordure inférieure bleue

### 📸 Capture d'Écran Attendue (Début)
```
┌─────────────────────────────────┐
│ 🤖 Assistant Personnel     ↻  ℹ️ │
├─────────────────────────────────┤
│ ███████░░░░░░░░░░░░░░░░░░░░░░░ │ ← Barre 0%
├─────────────────────────────────┤
│ 📊 0/28 étapes complétées (0%)  │ ← Badge bleu
├─────────────────────────────────┤
│                                 │
│  🤖 Salam Alaykoum ! 👋         │
│     Je suis votre assistant...  │
│                                 │
│                    [ Oui ] [Non]│
└─────────────────────────────────┘
```

### 🎬 Interaction - Progression
1. **Cliquer** sur "Oui"
2. **Attendre** la réponse du bot
3. **Observer** :
   - [ ] Barre de progression **augmente** (~4%)
   - [ ] Badge : **"1 / 28 étapes complétées (4%)"**

4. **Continuer** à répondre aux questions
5. **Après 5 étapes** :
   - [ ] Barre : ~18%
   - [ ] Badge : **"5 / 28 étapes complétées (18%)"**

### 📸 Capture d'Écran Attendue (Progression)
```
┌─────────────────────────────────┐
│ 🤖 Assistant Personnel     ↻  ℹ️ │
├─────────────────────────────────┤
│ ████████████░░░░░░░░░░░░░░░░░░ │ ← Barre 18%
├─────────────────────────────────┤
│ 📊 5/28 étapes complétées (18%) │ ← Badge bleu
├─────────────────────────────────┤
│                                 │
│  🤖 Le Sa'i comporte...         │
│                                 │
│  👤 Oui                          │
│                                 │
└─────────────────────────────────┘
```

### 🎬 Test Complet (28 Étapes)

**Si vous répondez à toutes les 28 étapes** :
- [ ] Barre de progression : **100% (verte)**
- [ ] Badge : Fond **vert** (`Colors.green[50]`)
- [ ] Icône : ✅ (check_circle)
- [ ] Texte : **"🎉 Félicitations ! Toutes les étapes terminées"**

### 📸 Capture d'Écran Attendue (100%)
```
┌─────────────────────────────────┐
│ 🤖 Assistant Personnel     ↻  ℹ️ │
├─────────────────────────────────┤
│ ███████████████████████████████ │ ← Barre 100% verte
├─────────────────────────────────┤
│ ✅ 🎉 Félicitations ! Toutes... │ ← Badge vert
├─────────────────────────────────┤
│                                 │
│  🤖 Mabrouk ! Tu as terminé...  │
│                                 │
└─────────────────────────────────┘
```

✅ **Test Réussi** : Progression affichée et mise à jour

---

## 🧪 Test 3 : Navigation Oui/Non Corrigée

### 🎬 Scénario 1 : Cliquer "Oui"
1. **Question** : "Es-tu prêt à commencer ton apprentissage ?"
2. **Boutons** : [ Oui ] [ Non ]
3. **Cliquer** : **Oui**
4. **Résultat attendu** :
   - [ ] Nouvelle question : **"As-tu déjà commencé à te préparer spirituellement pour le Hajj ?"**
   - [ ] Étape : `HAJJ_PREPARATION`
   - [ ] Pas de saut d'étapes ✅

### 🎬 Scénario 2 : Cliquer "Non"
1. **Recommencer** (bouton ↻ en haut à droite)
2. **Question** : "Es-tu prêt à commencer ton apprentissage ?"
3. **Cliquer** : **Non**
4. **Résultat attendu** :
   - [ ] Nouvelle question : **"Qu'est-ce qui te retient de commencer ton apprentissage maintenant ?"**
   - [ ] Étape : `HAJJ_MOTIVATION`
   - [ ] Champ de saisie texte (pas de boutons)

### 🎬 Scénario 3 : Parcours Complet
1. **Recommencer** (↻)
2. **Répondre** à toutes les questions logiquement
3. **Vérifier** :
   - [ ] Chaque réponse mène à la bonne étape suivante
   - [ ] Pas de message "Aucune étape suivante" ❌
   - [ ] Pas de retour à l'étape de félicitations prématurément ❌
   - [ ] Questions variées : YES_NO, MULTIPLE_CHOICE, TEXT
   - [ ] Arrivée finale : **"🎉 Mabrouk !"** (étape 24 ou 28)

### 📊 Tableau de Navigation Attendue

| Étape Actuelle | Réponse | Étape Suivante |
|----------------|---------|----------------|
| HAJJ_INTRO | Oui | HAJJ_PREPARATION |
| HAJJ_INTRO | Non | HAJJ_MOTIVATION |
| HAJJ_PREPARATION | Oui | IHRAM_KNOWLEDGE |
| HAJJ_PREPARATION | Non | SPIRITUAL_PREP_TIPS |
| TAWAF_INTRO | 7 tours | TAWAF_DIRECTION |
| TAWAF_INTRO | 5 tours | TAWAF_CORRECTION |
| TAWAF_INTRO | Je ne sais pas | TAWAF_EXPLAIN |

### ✅ Validation Complète
- [ ] Navigation logique et cohérente
- [ ] Toutes les 28 étapes accessibles
- [ ] Aucun crash ou boucle infinie
- [ ] Messages du bot appropriés

✅ **Test Réussi** : Navigation fonctionne correctement

---

## 🐛 Bugs à Reporter

### Si Vous Rencontrez un Problème

**Template de Bug Report** :
```markdown
## 🐛 Bug : [Titre Court]

### Étape où ça plante
- Étape : [Numéro et nom]
- Question : [Texte de la question]

### Action effectuée
- [Décrivez ce que vous avez fait]

### Résultat attendu
- [Ce qui devrait se passer]

### Résultat obtenu
- [Ce qui s'est vraiment passé]

### Logs d'erreur (si disponibles)
```
[Coller les logs du terminal ou console Chrome]
```

### Capture d'écran (si possible)
[Joindre capture d'écran]
```

### Exemples de Bugs Possibles

❌ **Bug 1** : "Cliquer sur Oui mène directement aux félicitations"
- **Cause probable** : SQL pas exécuté ou cache non rafraîchi
- **Solution** : Hot restart + vérifier les données SQL

❌ **Bug 2** : "Le bouton flottant ne tourne pas"
- **Cause probable** : Animation non lancée ou vsync problème
- **Solution** : Vérifier les logs Flutter

❌ **Bug 3** : "La progression ne s'affiche pas"
- **Cause probable** : `getProgressStats()` retourne vide
- **Solution** : Vérifier la table `user_conversation_progress`

---

## ✅ Checklist Finale

### Base de Données
- [ ] SEED_ASSISTANT_FIXED.sql exécuté
- [ ] 28 étapes présentes
- [ ] Clés de navigation en MAJUSCULES

### Bouton Flottant
- [ ] Visible sur toutes les pages sauf `/assistant`
- [ ] Animation de rotation fluide
- [ ] Effet respiration visible
- [ ] Halo lumineux présent
- [ ] Clic ouvre l'assistant

### Indicateur de Progression
- [ ] Barre de progression sous AppBar
- [ ] Badge "X/28 étapes complétées"
- [ ] Couleur bleue au début
- [ ] Couleur verte à 100%
- [ ] Mise à jour dynamique après chaque réponse

### Navigation
- [ ] Oui → étape correcte
- [ ] Non → étape alternative correcte
- [ ] QCM → navigation selon choix
- [ ] Parcours complet sans crash
- [ ] Arrivée aux félicitations à la fin

### Performance
- [ ] Aucun crash pendant 10 min
- [ ] Transitions fluides
- [ ] Pas de freeze ou lag
- [ ] Console Chrome sans erreurs critiques

---

## 📊 Résultats Attendus

### ✅ Tous les Tests Passent
**Félicitations ! Phase 1 (60%) complétée !** 🎉

**Prochaines étapes** :
1. Implémenter gestion d'erreurs (Phase 1.3)
2. Implémenter mode offline (Phase 1.4)
3. Passer à Phase 2 : Contenu Hajj enrichi

### ⚠️ Certains Tests Échouent
**Pas de panique !** Reportez les bugs et on les corrigera ensemble.

1. Noter tous les bugs rencontrés
2. Faire des captures d'écran
3. Copier les logs d'erreur
4. Demander de l'aide

---

## 🎉 Conclusion

Vous avez maintenant un bot Hajj :
- ✅ Avec navigation fonctionnelle
- ✅ Accessible partout via bouton flottant animé
- ✅ Avec feedback visuel de progression
- ✅ Prêt pour les prochaines améliorations

**Excellent travail !** 🚀

---

*Guide créé le 23 Octobre 2025*  
*Pour tester Phase 1 (60%) du Bot Hajj*  
*Projet : Sahabi Guide*

