# Guide d'intégration Airalo eSIM - Sahabi Guide

## 📋 Vue d'ensemble

Ce guide documente l'intégration complète d'Airalo Partners API v2 dans le système Sahabi Guide pour permettre aux pèlerins d'acheter des forfaits eSIM pour le Hajj en Arabie Saoudite.

## ✅ Fonctionnalités implémentées

### Backend (Spring Boot)

1. **Modèle de données étendu** (migration Liquibase 026)
   - Extension de `connectivity_plans` avec métadonnées Airalo
   - Extension de `connectivity_subscriptions` pour tracking complet eSIM
   - Nouvelle table `connectivity_orders` pour traçabilité des achats
   - Nouvelle table `connectivity_usage_snapshots` pour historique de consommation
   - Nouvelle table `device_compatibility_cache` pour performance

2. **Client Airalo API v2** (`AiraloApiClient`)
   - Authentification OAuth2 avec cache automatique du token
   - Récupération des packages par pays (ex: Arabie Saoudite)
   - Soumission de commandes d'eSIM
   - Récupération de l'usage (data, voix, SMS)
   - Support Sandbox et Production via configuration

3. **Service de compatibilité des appareils** (`DeviceCompatibilityService`)
   - Règles locales pour iOS (iPhone XR+ avec iOS 12+)
   - Règles locales pour Android (Pixel 3+, Samsung S20+, etc. avec Android 10+)
   - Cache en base de données (validité 30 jours)
   - API simple pour vérification depuis mobile

4. **Service d'achat eSIM** (`EsimPurchaseService`)
   - Workflow complet d'achat avec traçabilité
   - Synchronisation des packages Airalo vers la DB
   - Gestion des commandes (PENDING → PROCESSING → COMPLETED/FAILED)
   - Tracking de l'usage avec snapshots
   - Historique des achats par utilisateur

5. **Endpoints REST** (dans `ConnectivityController`)
   - `GET /api/v1/connectivity/plans` - Liste des forfaits disponibles
   - `GET /api/v1/connectivity/device-compatibility` - Vérifier compatibilité appareil
   - `POST /api/v1/connectivity/purchase` - Acheter un eSIM
   - `GET /api/v1/connectivity/orders` - Historique des commandes
   - `GET /api/v1/connectivity/my-esims` - Mes eSIM actifs
   - `GET /api/v1/connectivity/subscriptions/{id}/usage` - Usage d'un eSIM
   - `POST /api/v1/connectivity/admin/sync-airalo-packages` - Sync packages (admin)

## 🔧 Configuration

### Variables d'environnement requises

#### Production
```bash
# Airalo API
AIRALO_ENABLED=true
AIRALO_BASE_URL=https://partners-api.airalo.com  # Production
AIRALO_CLIENT_ID=your_production_client_id       # À obtenir de Airalo
AIRALO_CLIENT_SECRET=your_production_secret      # À obtenir de Airalo
```

#### Sandbox / Test
```bash
# Airalo API (Sandbox)
AIRALO_ENABLED=true
AIRALO_BASE_URL=https://sandbox-partners-api.airalo.com  # Sandbox
AIRALO_CLIENT_ID=your_sandbox_client_id
AIRALO_CLIENT_SECRET=your_sandbox_secret
```

#### Développement local
Les valeurs par défaut dans `application-dev.yml` suffisent (mode mock activé).

### Fichiers de configuration modifiés

- `sahabi-guide-api/src/main/resources/application-dev.yml`
- `sahabi-guide-api/src/main/resources/application-prod.yml`
- `sahabi-guide-api/src/main/resources/application-cloud.yml`

## 🚀 Démarrage rapide

### 1. Appliquer les migrations de base de données

```bash
# Les migrations Liquibase s'appliquent automatiquement au démarrage
# Migration 026 sera exécutée
```

### 2. Synchroniser les packages Airalo

Via l'API (authentification admin requise) :
```bash
curl -X POST "http://localhost:8080/api/v1/connectivity/admin/sync-airalo-packages?countryCode=SA" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

Cela récupère tous les forfaits Airalo pour l'Arabie Saoudite et les enregistre en base.

### 3. Tester la compatibilité d'un appareil

```bash
curl "http://localhost:8080/api/v1/connectivity/device-compatibility?platform=ios&osVersion=17.4&deviceModel=iPhone%2012"
```

Réponse :
```json
{
  "compatible": true,
  "reason": "IOS_COMPATIBLE",
  "platform": "ios",
  "osVersion": "17.4",
  "deviceModel": "iPhone 12",
  "source": "local_rules"
}
```

### 4. Acheter un eSIM (utilisateur authentifié)

```bash
curl -X POST "http://localhost:8080/api/v1/connectivity/purchase" \
  -H "Authorization: Bearer USER_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "planId": "uuid-du-plan",
    "paymentMethod": "cash",
    "paymentReference": "REF123"
  }'
```

Réponse :
```json
{
  "orderId": "uuid-commande",
  "subscriptionId": "uuid-subscription",
  "status": "SUCCESS",
  "iccid": "8912345678901234567",
  "qrCode": "LPA:1$rsp.airalo.com$ACTIVATION-CODE",
  "activationCode": "ACTIVATION-CODE",
  "installUrl": "https://airalo.com/install/...",
  "message": "eSIM acheté avec succès..."
}
```

## 📱 Intégration Flutter (à implémenter)

### Fonctionnalités à créer côté mobile

#### 1. Vérification de compatibilité au premier lancement

```dart
class DeviceCompatibilityChecker {
  Future<CompatibilityResult> checkCompatibility() async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    final osVersion = await getOsVersion(); // Ex: "17.4"
    final deviceModel = await getDeviceModel(); // Ex: "iPhone 12"
    
    final response = await apiClient.get(
      '/connectivity/device-compatibility',
      queryParameters: {
        'platform': platform,
        'osVersion': osVersion,
        'deviceModel': deviceModel,
      },
    );
    
    return CompatibilityResult.fromJson(response.data);
  }
}
```

#### 2. Écran de liste des forfaits

```dart
class EsimPackagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConnectivityPlan>>(
      future: apiClient.get('/connectivity/plans'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        final plans = snapshot.data!;
        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return EsimPackageCard(
              plan: plan,
              onPurchase: () => _purchaseEsim(plan),
            );
          },
        );
      },
    );
  }
  
  Future<void> _purchaseEsim(ConnectivityPlan plan) async {
    // Afficher confirmation
    final confirmed = await showDialog<bool>(...);
    if (!confirmed) return;
    
    // Acheter
    final response = await apiClient.post(
      '/connectivity/purchase',
      data: {
        'planId': plan.id,
        'paymentMethod': 'cash',
      },
    );
    
    // Afficher QR code et instructions d'installation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EsimInstallationScreen(
          qrCode: response.data['qrCode'],
          activationCode: response.data['activationCode'],
        ),
      ),
    );
  }
}
```

#### 3. Écran d'installation avec QR code

```dart
class EsimInstallationScreen extends StatelessWidget {
  final String qrCode;
  final String activationCode;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Installer votre eSIM')),
      body: Column(
        children: [
          // Afficher le QR code
          QrImageView(
            data: qrCode,
            size: 300,
          ),
          
          // Instructions
          Text('1. Ouvrez Réglages > Données cellulaires'),
          Text('2. Appuyez sur "Ajouter un forfait cellulaire"'),
          Text('3. Scannez le QR code ci-dessus'),
          
          // Code d'activation manuel en fallback
          ExpansionTile(
            title: Text('Code d\'activation manuel'),
            children: [
              SelectableText(activationCode),
            ],
          ),
          
          // Bouton pour copier le code
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: activationCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Code copié !')),
              );
            },
            child: Text('Copier le code d\'activation'),
          ),
        ],
      ),
    );
  }
}
```

#### 4. Écran de suivi de consommation

```dart
class EsimUsageScreen extends StatelessWidget {
  final String subscriptionId;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UsageInfo>(
      future: apiClient.get('/connectivity/subscriptions/$subscriptionId/usage'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        final usage = snapshot.data!;
        final percentUsed = (usage.dataUsedMb / usage.dataTotalMb * 100).toInt();
        
        return Column(
          children: [
            // Jauge de consommation
            CircularProgressIndicator(
              value: percentUsed / 100,
              backgroundColor: Colors.grey[200],
              strokeWidth: 15,
            ),
            Text('$percentUsed% utilisé'),
            
            // Détails
            ListTile(
              leading: Icon(Icons.data_usage),
              title: Text('Données utilisées'),
              subtitle: Text('${usage.dataUsedMb} MB / ${usage.dataTotalMb} MB'),
            ),
            
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Appels'),
              subtitle: Text('${usage.voiceUsedSeconds ~/ 60} minutes'),
            ),
            
            ListTile(
              leading: Icon(Icons.sms),
              title: Text('SMS envoyés'),
              subtitle: Text('${usage.smsUsedCount}'),
            ),
            
            // Rafraîchir
            ElevatedButton(
              onPressed: () {
                // Recharger
                setState(() {});
              },
              child: Text('Actualiser'),
            ),
          ],
        );
      },
    );
  }
}
```

#### 5. Modèles de données Flutter

Créer les fichiers suivants dans `sahabi-guide-front/lib/models/` :

- `connectivity_plan.dart`
- `esim_purchase_response.dart`
- `device_compatibility_result.dart`
- `usage_info.dart`
- `connectivity_order.dart`

Exemple :
```dart
class ConnectivityPlan {
  final String id;
  final String name;
  final double dataGb;
  final double price;
  final String partner;
  final bool active;
  final int? validityDays;
  final String? countryCode;
  
  ConnectivityPlan.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      dataGb = (json['dataGb'] as num).toDouble(),
      price = (json['price'] as num).toDouble(),
      partner = json['partner'],
      active = json['active'],
      validityDays = json['validityDays'],
      countryCode = json['countryCode'];
}
```

## 🔍 Tests

### Tests backend

```bash
cd sahabi-guide-api

# Tests d'intégration du client Airalo (nécessite clés sandbox)
mvn test -Dtest=AiraloApiClientTest

# Tests du service de compatibilité
mvn test -Dtest=DeviceCompatibilityServiceTest

# Tests du service d'achat
mvn test -Dtest=EsimPurchaseServiceTest
```

### Tests manuels via Postman/Insomnia

Importer la collection d'exemples de requêtes (à créer).

## 📊 Monitoring

### Logs à surveiller

```bash
# Logs d'authentification Airalo
grep "Token d'accès Airalo" logs/sahabi-api.log

# Logs d'achat
grep "Achat eSIM" logs/sahabi-api.log

# Logs d'erreurs Airalo
grep "Erreur lors de l'appel API Airalo" logs/sahabi-api.log
```

### Métriques importantes

- Nombre de commandes par statut (COMPLETED, FAILED, PENDING)
- Temps de réponse de l'API Airalo
- Taux de succès des achats
- Taux d'appareils compatibles vs incompatibles

### Requêtes SQL utiles

```sql
-- Statistiques des commandes
SELECT status, COUNT(*) 
FROM connectivity_orders 
GROUP BY status;

-- Revenus par période
SELECT DATE(created_at) as date, 
       COUNT(*) as orders, 
       SUM(amount_paid) as revenue
FROM connectivity_orders
WHERE status = 'COMPLETED'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Packages les plus vendus
SELECT p.name, COUNT(o.id) as sales
FROM connectivity_orders o
JOIN connectivity_plans p ON o.plan_id = p.id
WHERE o.status = 'COMPLETED'
GROUP BY p.name
ORDER BY sales DESC;

-- Apparareils testés pour compatibilité
SELECT platform, is_compatible, COUNT(*) as count
FROM device_compatibility_cache
GROUP BY platform, is_compatible;
```

## ⚠️ Points d'attention

### Sécurité

1. **Tokens Airalo** : Ne JAMAIS exposer `client_secret` dans le frontend ou les logs
2. **Authentification** : Tous les endpoints d'achat nécessitent un JWT valide
3. **Validation** : Toujours vérifier que l'utilisateur possède bien la souscription qu'il consulte

### Performance

1. **Cache** : La compatibilité des appareils est cachée 30 jours
2. **Tokens** : Le token Airalo est caché jusqu'à expiration (moins 5 min de marge)
3. **Snapshots** : Limiter la fréquence de synchronisation de l'usage (max 1x/heure recommandé)

### Gestion des erreurs

1. **Airalo down** : Le système passe en mode dégradé (commandes PENDING)
2. **Timeout** : Retries automatiques (max 3 tentatives avec backoff exponentiel)
3. **Conflits** : Éviter les achats multiples simultanés pour un même utilisateur

## 🆘 Support

### Problèmes courants

**Erreur "Token d'accès invalide"**
- Vérifier `AIRALO_CLIENT_ID` et `AIRALO_CLIENT_SECRET`
- Vérifier que l'URL de base est correcte (sandbox vs prod)

**Appareil détecté comme incompatible alors qu'il l'est**
- Ajouter le modèle dans `DeviceCompatibilityService`
- Ou modifier la regex de détection

**Commande bloquée en PENDING**
- Vérifier les logs Airalo
- Utiliser l'endpoint admin pour investiguer
- Possibilité de repasser la commande manuellement

### Documentation Airalo

- [API Documentation](https://partners-doc.airalo.com/)
- [Support Airalo Partners](mailto:partners@airalo.com)

## 📝 TODO / Améliorations futures

- [ ] Webhooks Airalo pour notifications de changement de statut
- [ ] Système de notifications push quand données faibles
- [ ] Support multi-devises (actuellement USD uniquement)
- [ ] Facturation automatique (PDF) par email
- [ ] Recharge automatique si solde < seuil
- [ ] Statistiques avancées dans le dashboard admin
- [ ] Tests end-to-end automatisés
- [ ] Support eSIM multi-pays (si nécessaire)

## 👥 Contacts

- Backend Lead: [votre-email]
- Mobile Lead: [votre-email]
- DevOps: [votre-email]

---

**Dernière mise à jour** : Novembre 2025
**Version** : 1.0.0


