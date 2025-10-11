pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProperties = file("local.properties")
        if (localProperties.exists()) {
            localProperties.inputStream().use { properties.load(it) }
            properties.getProperty("flutter.sdk")
        } else {
            // For CI environment where local.properties might not exist
            System.getenv("FLUTTER_ROOT") ?: System.getenv("FLUTTER_SDK")
        }?.also {
            println("Using Flutter SDK at: $it")
        } ?: error("Flutter SDK not found. Set FLUTTER_ROOT environment variable or flutter.sdk in local.properties")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }

    resolutionStrategy {
        eachPlugin {
            if (requested.id.namespace == "com.android.application") {
                useModule("com.android.tools.build:gradle:${requested.version}")
            }
        }
    }
}

// Enable Gradle's version catalog support
enableFeaturePreview("VERSION_CATALOGS")

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
