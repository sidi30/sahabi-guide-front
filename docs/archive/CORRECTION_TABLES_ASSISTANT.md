# ✅ Correction Tables Assistant

## 🐛 Problèmes Rencontrés

### 1. UUID Invalid: "current-user-id"
```
Invalid UUID string: current-user-id
```
**Cause** : Le frontend envoyait un texte au lieu d'un UUID valide.

### 2. Table Missing
```
ERREUR: la relation « conversation_steps » n'existe pas
```
**Cause** : Les tables n'ont pas été créées par Liquibase.

---

## ✅ Corrections Appliquées

### 1. Backend : Ajout au Changelog Liquibase

**Fichier** : `sahabi-guide-api/src/main/resources/db/changelog/db.changelog-master.xml`

```xml
<!-- Assistant Conversationnel -->
<include file="changes/015-create-assistant-tables.xml" relativeToChangelogFile="true"/>
```

### 2. Frontend : UUID Valide de Test

**Fichier** : `sahabi-guide-front/lib/features/assistant/presentation/providers/assistant_provider.dart`

**Avant** :
```dart
const userId = 'current-user-id';  // ❌ Texte invalide
```

**Après** :
```dart
// UUID de test valide pour le développement
const userId = '123e4567-e89b-12d3-a456-426614174000';  // ✅ UUID valide
```

---

## 🚀 Actions à Effectuer

### Étape 1 : Redémarrer le Backend

Le backend doit redémarrer pour que Liquibase crée les 3 tables :
- `conversation_steps`
- `user_conversation_progress`
- `conversation_sessions`

**Commandes** :

#### Option A : Maven Wrapper (Recommandé)
```bash
cd sahabi-guide-api

# Windows
mvnw.cmd spring-boot:run

# Linux/Mac
./mvnw spring-boot:run
```

#### Option B : Maven Direct
```bash
cd sahabi-guide-api
mvn spring-boot:run
```

**Résultat attendu** : Dans les logs, vous verrez :
```
Liquibase: Successfully executed changeSet: changes/015-create-assistant-tables.xml
Tomcat started on port(s): 8084 (http)
```

---

### Étape 2 : Seed les 24 Étapes Conversationnelles

Une fois le backend démarré :

#### Option A : Via Script SQL (Recommandé)
```bash
# Connectez-vous à PostgreSQL
psql -U postgres -d sahabi_guide

# Exécutez le script
\i sahabi-guide-api/scripts/seed_conversation_steps.sql

# Quitter
\q
```

#### Option B : Via DBeaver/pgAdmin
1. Ouvrir le fichier `sahabi-guide-api/scripts/seed_conversation_steps.sql`
2. Copier tout le contenu
3. Exécuter dans la console SQL

#### Option C : Via curl (si API existe)
```bash
curl -X POST http://localhost:8084/api/v1/assistant/seed
```

---

### Étape 3 : Vérifier les Tables

**SQL de vérification** :

```sql
-- Vérifier que les tables existent
SELECT table_name 
FROM information_schema.tables 
WHERE table_name LIKE 'conversation%';

-- Résultat attendu :
--  conversation_sessions
--  conversation_steps
--  user_conversation_progress

-- Vérifier les 24 étapes
SELECT COUNT(*) FROM conversation_steps;

-- Résultat attendu : 24
```

---

### Étape 4 : Relancer l'Application Flutter

L'application Flutter tourne déjà, mais pour prendre en compte les changements :

#### Option A : Hot Reload (Rapide)
Appuyez sur **`R`** dans le terminal où Flutter tourne.

#### Option B : Restart Complet (Recommandé)
```bash
# Dans le terminal Flutter
q  # Quitter

# Relancer
cd sahabi-guide-front
flutter run -d chrome
```

---

## 🧪 Test Complet

### 1. Vérifier que le Backend Tourne

```bash
curl http://localhost:8084/api/v1/assistant/steps
```

**Résultat attendu** :
```json
[
  {
    "id": "uuid...",
    "stepCode": "HAJJ_INTRO",
    "stepOrder": 1,
    "question": "Salam Alaykoum ! Je suis votre assistant personnel...",
    ...
  },
  ...
]
```

### 2. Tester l'Assistant dans l'App

1. Ouvrez l'app Flutter sur Chrome
2. Allez sur la page d'accueil
3. Cliquez sur "🤖 Assistant"
4. Vous devriez voir :
   ```
   👋 Salam Alaykoum !
   Je suis votre assistant...
   
   [Oui]  [Non]
   ```

---

## 📝 Structure des Tables Créées

### conversation_steps
```sql
id                   UUID PRIMARY KEY
step_code            VARCHAR(255) UNIQUE -- 'HAJJ_INTRO', 'HAJJ_PREPARATION', etc.
step_order           INTEGER             -- 1, 2, 3, ...
question             TEXT                -- Question en français
question_ar          TEXT                -- Question en arabe (optionnel)
question_en          TEXT                -- Question en anglais (optionnel)
answer_type          VARCHAR(50)         -- 'YES_NO', 'MULTIPLE_CHOICE', 'TEXT'
answer_options_json  JSONB               -- ["Oui", "Non"] ou choix multiples
navigation_rules_json JSONB              -- Règles de navigation
next_step_code       VARCHAR(255)        -- Code de l'étape suivante
help_text            TEXT                -- Aide contextuelle
related_ritual_id    UUID                -- Lien vers un rituel (optionnel)
is_critical          BOOLEAN             -- Question critique ?
reminder_after_hours INTEGER             -- Rappel après X heures
created_at           TIMESTAMP
updated_at           TIMESTAMP
```

### user_conversation_progress
```sql
id                UUID PRIMARY KEY
user_id           UUID FOREIGN KEY → users(id)
step_id           UUID FOREIGN KEY → conversation_steps(id)
answer            TEXT
answered_at       TIMESTAMP
synced_at         TIMESTAMP (NULL si offline)
metadata_json     JSONB
device_id         VARCHAR(255)
is_offline        BOOLEAN
reminder_sent_at  TIMESTAMP
reminder_count    INTEGER
created_at        TIMESTAMP
updated_at        TIMESTAMP
UNIQUE (user_id, step_id)  -- Un utilisateur ne peut répondre qu'une fois par étape
```

### conversation_sessions
```sql
id                   UUID PRIMARY KEY
user_id              UUID FOREIGN KEY → users(id)
current_step_id      UUID FOREIGN KEY → conversation_steps(id)
status               VARCHAR(50)  -- 'ACTIVE', 'PAUSED', 'COMPLETED'
started_at           TIMESTAMP
last_interaction_at  TIMESTAMP
completed_at         TIMESTAMP
session_data_json    JSONB
created_at           TIMESTAMP
updated_at           TIMESTAMP
```

---

## ✅ Checklist

Avant de tester l'assistant, vérifiez :

- [ ] Backend redémarré avec Liquibase
- [ ] 3 tables créées (`conversation_steps`, `user_conversation_progress`, `conversation_sessions`)
- [ ] 24 étapes seedées dans `conversation_steps`
- [ ] Endpoint `/api/v1/assistant/steps` accessible
- [ ] Frontend modifié avec UUID valide
- [ ] App Flutter relancée

---

## 🔧 Si Problème Persiste

### Backend ne démarre pas
```bash
# Nettoyer et recompiler
cd sahabi-guide-api
mvn clean package -DskipTests
mvn spring-boot:run
```

### Tables non créées
**Vérifier le profil** : Les tables ne se créent que si le profil inclut le changeset.

```properties
# application.yml
spring:
  profiles:
    active: dev
  liquibase:
    enabled: true
    change-log: classpath:db/changelog/db.changelog-master.xml
```

### Seed échoue
**Créer les tables manuellement** :

```sql
-- Copier le contenu de:
-- sahabi-guide-api/scripts/seed_conversation_steps.sql
-- Lignes 5-62 : CREATE TABLE statements
```

---

## 🎉 Résumé

1. ✅ **Liquibase** : Migration ajoutée au changelog
2. ✅ **Frontend** : UUID valide au lieu de texte
3. ⏳ **Action** : Redémarrer le backend
4. ⏳ **Action** : Seed les 24 étapes
5. ⏳ **Action** : Relancer l'app Flutter

**Après ces étapes, l'assistant fonctionnera parfaitement ! 🤖**

---

*Correction Tables Assistant - Sahabi Guide*  
*23 Octobre 2025*

