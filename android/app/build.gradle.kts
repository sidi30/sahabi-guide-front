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
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }

    defaultConfig {
        // Application ID for Sahabi Guide
        applicationId = "com.sahabi_guide.sahabi_guide"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk 24 requis par flutter_tts 4.x (APIs audio Android N+)
        minSdk = 24
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
        // IMPORTANT: Ne jamais committer de clé API en dur dans le code
        val googleMapsApiKey = localProperties.getProperty("googleMapsApiKey")
            ?: System.getenv("GOOGLE_MAPS_API_KEY")
            ?: throw GradleException("Google Maps API Key is required. Set 'googleMapsApiKey' in local.properties or GOOGLE_MAPS_API_KEY environment variable.")

        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey

        // NDK ABI Filters pour optimiser la taille de l'APK
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    // Splitting APK par architecture pour réduire la taille
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true // Générer aussi un APK universel
        }
    }

    // Configuration de signing pour release
    signingConfigs {
        // Lire les propriétés de signing depuis key.properties
        val keystoreProperties = Properties()
        val keystorePropertiesFile = rootProject.file("key.properties")
        if (keystorePropertiesFile.exists()) {
            keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
        }
        
        create("release") {
            val keystoreFile = keystoreProperties.getProperty("storeFile")
            if (keystoreFile != null) {
                storeFile = rootProject.file(keystoreFile)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
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
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
            }
            
            signingConfig = if (keystoreProperties.getProperty("storeFile") != null) {
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
