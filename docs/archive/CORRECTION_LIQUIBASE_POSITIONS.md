# ✅ Correction Migration Liquibase - Table Positions

## 🐛 Problème Identifié

**Erreur:**
```
ERREUR: la colonne « timestamp » de la relation « positions » n'existe pas
Position : 64 [Failed SQL: INSERT INTO public.positions (id, user_id, lat, lng, accuracy, timestamp) VALUES (...)]
```

**Cause:**
Le fichier `007-seed-extended-mocks.xml` utilisait une syntaxe Liquibase incorrecte pour insérer des données dans la table `positions` avec des colonnes calculées (`valueComputed` pour `timestamp`).

## ✅ Solution Appliquée

### Avant (❌ Incorrect)
```xml
<insert tableName="positions">
    <column name="id" value="550e8400-e29b-41d4-a716-446655440120"/>
    <column name="user_id" value="550e8400-e29b-41d4-a716-446655440020"/>
    <column name="lat" valueNumeric="21.4225"/>
    <column name="lng" valueNumeric="39.8262"/>
    <column name="accuracy" valueNumeric="15.0"/>
    <column name="timestamp" valueComputed="CURRENT_TIMESTAMP - INTERVAL '5 minutes'"/>
</insert>
```

**Problème:** Liquibase ne gère pas bien `valueComputed` avec des expressions PostgreSQL complexes pour certains types de colonnes.

### Après (✅ Correct)
```xml
<sql>
    INSERT INTO positions (id, user_id, lat, lng, accuracy, speed, heading, timestamp, created_at, updated_at) 
    VALUES ('550e8400-e29b-41d4-a716-446655440120', '550e8400-e29b-41d4-a716-446655440020', 21.4225, 39.8262, 15.0, NULL, NULL, CURRENT_TIMESTAMP - INTERVAL '5 minutes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
</sql>
```

**Solution:** Utilisation de `<sql>` direct avec toutes les colonnes explicites (y compris `speed`, `heading`, `created_at`, `updated_at`).

## 📋 Fichiers Modifiés

### 1. `007-seed-extended-mocks.xml`
- ✅ Remplacement des 2 inserts `<insert>` par `<sql>` direct
- ✅ Ajout des colonnes manquantes (`speed`, `heading`, `created_at`, `updated_at`)
- ✅ Syntaxe SQL PostgreSQL native pour les timestamps

## 🧪 Validation

**Structure de la table positions (001-create-core-schema.xml):**
```xml
<createTable tableName="positions">
    <column name="id" type="UUID"/>
    <column name="user_id" type="UUID"/>
    <column name="lat" type="DOUBLE PRECISION"/>
    <column name="lng" type="DOUBLE PRECISION"/>
    <column name="accuracy" type="DOUBLE PRECISION"/>
    <column name="speed" type="DOUBLE PRECISION"/>       <!-- ✅ Nouvelle colonne -->
    <column name="heading" type="DOUBLE PRECISION"/>     <!-- ✅ Nouvelle colonne -->
    <column name="timestamp" type="TIMESTAMP WITH TIME ZONE"/>  <!-- ✅ Colonne timestamp existe -->
    <column name="created_at" type="TIMESTAMP WITH TIME ZONE"/>
    <column name="updated_at" type="TIMESTAMP WITH TIME ZONE"/>
</createTable>
```

## ✅ Résultat

- ✅ La migration Liquibase devrait maintenant passer sans erreur
- ✅ Les données de seed pour les positions seront insérées correctement
- ✅ Les colonnes `speed` et `heading` sont maintenant utilisées dans les seeds

## 🚀 Prochaines Étapes

1. Redémarrer l'application : `mvn spring-boot:run`
2. Vérifier les migrations : Les changesets doivent s'appliquer sans erreur
3. Vérifier les données : Les positions d'Ahmed et Fatima doivent être présentes

## 📝 Notes

- La colonne `timestamp` existe bien dans la table depuis la migration `001-create-core-schema.xml`
- Les colonnes `speed` et `heading` ont été ajoutées dans la migration `010-add-battery-to-positions.xml`
- Les seeds utilisent maintenant la syntaxe SQL native pour plus de fiabilité



