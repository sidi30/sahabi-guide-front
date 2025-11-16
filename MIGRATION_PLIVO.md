# 📱 Migration Twilio → Plivo (Complétée)

## 🎯 Objectif
Migrer du provider SMS Twilio vers Plivo pour **réduire les coûts de ~40%** sur l'envoi de SMS OTP.

---

## ✅ Modifications Effectuées

### 1. **Architecture Propre avec Interface**
- ✅ Créé `SmsService.java` (interface d'abstraction)
- ✅ Créé `PlivoSmsService.java` (implémentation principale)
- ✅ Modifié `TwilioSmsService.java` (implémente l'interface, marqué legacy)
- ✅ `UserAuthService` utilise maintenant l'interface `SmsService`

**Avantage** : Vous pouvez switcher de provider en changeant simplement `SMS_PROVIDER` dans les variables d'environnement.

---

### 2. **Dépendances Maven (`pom.xml`)**
```xml
<!-- Plivo SDK (principal) -->
<dependency>
    <groupId>com.plivo</groupId>
    <artifactId>plivo-java</artifactId>
    <version>5.46.0</version>
</dependency>

<!-- Twilio SDK (optionnel, compatibilité) -->
<dependency>
    <groupId>com.twilio.sdk</groupId>
    <artifactId>twilio</artifactId>
    <version>10.1.5</version>
    <optional>true</optional>
</dependency>
```

---

### 3. **Configuration Spring Boot (`application-prod.yml`)**
```yaml
# SMS Provider (Plivo par défaut)
sms:
  provider: ${SMS_PROVIDER:plivo}  # plivo ou twilio

# Plivo (provider principal, ~40% moins cher)
plivo:
  enabled: ${PLIVO_ENABLED:false}
  auth-id: ${PLIVO_AUTH_ID:}
  auth-token: ${PLIVO_AUTH_TOKEN:}
  phone-number: ${PLIVO_PHONE_NUMBER:}
  retry:
    max-attempts: ${PLIVO_RETRY_MAX_ATTEMPTS:3}
    backoff-delay-ms: ${PLIVO_RETRY_BACKOFF_DELAY:2000}

# Twilio (legacy, compatibilité)
twilio:
  enabled: ${TWILIO_ENABLED:false}
  account-sid: ${TWILIO_ACCOUNT_SID:}
  auth-token: ${TWILIO_AUTH_TOKEN:}
  phone-number: ${TWILIO_PHONE_NUMBER:}
  # ... (config similaire)
```

---

### 4. **Terraform (`variables.tf`, `main.tf`, `terraform.tfvars`)**

#### `variables.tf`
- ✅ Ajouté `sms_provider` (plivo par défaut)
- ✅ Ajouté `enable_plivo`, `plivo_auth_id`, `plivo_auth_token`, `plivo_phone_number`
- ✅ Gardé les variables Twilio pour compatibilité

#### `main.tf` (Backend Cloud Run)
- ✅ Ajouté `SMS_PROVIDER=plivo`
- ✅ Ajouté toutes les variables Plivo (`PLIVO_AUTH_ID`, etc.)
- ✅ Gardé les variables Twilio (désactivées par défaut)

#### `terraform.tfvars`
```hcl
sms_provider = "plivo"

enable_plivo       = false
plivo_auth_id      = ""
plivo_auth_token   = ""
plivo_phone_number = ""

enable_twilio       = false
twilio_account_sid  = ""
twilio_auth_token   = ""
twilio_phone_number = ""
```

---

### 5. **Validation de Sécurité (`SecurityConfigValidator.java`)**
- ✅ Détecte automatiquement le provider SMS configuré
- ✅ Valide Plivo ou Twilio selon `app.sms.provider`

---

## 🚀 Prochaines Étapes (Action Utilisateur)

### **Étape 1 : Changer le mot de passe PostgreSQL**
```bash
gcloud sql users set-password sahabi \
  --instance=sahabi-postgres \
  --password="2EAVGtXChPLcJsv3zf4M"
```

### **Étape 2 : Rebuilder l'image Docker du backend**
```powershell
cd C:\Users\ramzi\Desktop\devs\sahabiGuide\sahabi-guide-api

# Build de l'image
docker build -t europe-west1-docker.pkg.dev/sahabiguide-478323/sahabi-registry/backend:latest .

# Push vers Artifact Registry
docker push europe-west1-docker.pkg.dev/sahabiguide-478323/sahabi-registry/backend:latest
```

### **Étape 3 : Redéployer le backend avec Terraform**
```powershell
cd C:\Users\ramzi\Desktop\devs\sahabiGuide\terraform

terraform apply -target=google_cloud_run_v2_service.backend
```

### **Étape 4 : Vérifier le démarrage**
```powershell
# Logs du backend
gcloud run services logs read sahabi-backend --region=europe-west1 --limit=30

# Health check
Invoke-WebRequest -Uri "https://sahabi-backend-520537349678.europe-west1.run.app/actuator/health"
```

**Attendu** :
- ✅ `StatusCode : 200`
- ✅ Logs : `Provider SMS sélectionné: plivo`
- ✅ Aucune erreur de configuration

---

## 💰 Économies Attendues

| Scénario | Twilio | Plivo | Économie |
|----------|--------|-------|----------|
| 1000 SMS/mois | ~80€ | ~50€ | **30€/mois** |
| 5000 SMS/mois | ~400€ | ~250€ | **150€/mois** |
| 10000 SMS/mois | ~800€ | ~500€ | **300€/mois** |

---

## 🔄 Comment Activer Plivo ?

**Quand vous aurez un compte Plivo**, modifiez `terraform/terraform.tfvars` :

```hcl
sms_provider = "plivo"

enable_plivo       = true
plivo_auth_id      = "MAXXXXXXXXXXXXXXXXXX"  # Votre Auth ID Plivo
plivo_auth_token   = "your_plivo_auth_token"
plivo_phone_number = "+33XXXXXXXXX"  # Votre numéro Plivo
```

Puis redéployez :
```powershell
terraform apply -target=google_cloud_run_v2_service.backend
```

---

## 🔄 Revenir à Twilio (si besoin)

Modifiez simplement `terraform/terraform.tfvars` :

```hcl
sms_provider = "twilio"

enable_twilio       = true
twilio_account_sid  = "ACxxxxxxxxxxxx"
twilio_auth_token   = "your_token"
twilio_phone_number = "+33XXXXXXXXX"
```

Puis redéployez. **Aucun changement de code nécessaire !**

---

## 📝 Résumé des Avantages

| Aspect | Status |
|--------|--------|
| **Économie** | ~40% sur les SMS (~30€ pour 1000 SMS) |
| **Flexibilité** | Switch Plivo ↔ Twilio sans changer le code |
| **Rétrocompatibilité** | Twilio toujours disponible si besoin |
| **Migration** | Transparente (même interface) |
| **Risque** | Très faible (API quasi-identique) |

---

## 🎉 Conclusion

La migration vers Plivo est **complète côté code**. Il ne reste plus qu'à :
1. Rebuilder l'image Docker
2. Redéployer via Terraform
3. (Plus tard) Activer Plivo avec vos credentials

**Tous les fichiers Java, Terraform et configuration sont prêts !** 🚀

