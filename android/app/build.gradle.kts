import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sahabi_guide.sahabi_guide"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        // Application ID for Sahabi Guide
        applicationId = "com.sahabi_guide.sahabi_guide"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Assurer que versionCode est bien un entier (tiré de pubspec.yaml)
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        
        // Lire la clé Google Maps depuis local.properties
        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { localProperties.load(it) }
        }
        
        // Google Maps API Key (depuis local.properties ou variable d'environnement)
        val googleMapsApiKey = localProperties.getProperty("googleMapsApiKey") 
            ?: System.getenv("GOOGLE_MAPS_API_KEY") 
            ?: "AIzaSyBNUp3s4kAS7LRHScAUJezSRKSrTv7YnGk"  // Clé de dev par défaut
        
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
    }

    // Configuration de signing pour release
    signingConfigs {
        // Lire les propriétés de signing depuis local.properties
        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { localProperties.load(it) }
        }
        
        create("release") {
            val keystoreFile = localProperties.getProperty("storeFile")
            if (keystoreFile != null) {
                storeFile = file(keystoreFile)
                storePassword = localProperties.getProperty("storePassword")
                keyAlias = localProperties.getProperty("keyAlias")
                keyPassword = localProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
        }
        
        release {
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard pour l'obfuscation et l'optimisation
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Utiliser la config de signing release si disponible, sinon debug
            val localProperties = Properties()
            val localPropertiesFile = rootProject.file("local.properties")
            if (localPropertiesFile.exists()) {
                localPropertiesFile.inputStream().use { localProperties.load(it) }
            }
            
            signingConfig = if (localProperties.getProperty("storeFile") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter { source = "../.." }

dependencies {
    // Core library desugaring for Java 8+ APIs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
