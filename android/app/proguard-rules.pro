## ====================================
## SAHABI GUIDE - RÈGLES PROGUARD
## ====================================
## Ce fichier contient les règles ProGuard pour l'obfuscation
## et l'optimisation de l'application en production

## ====================================
## RÈGLES FLUTTER
## ====================================
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

## ====================================
## RÈGLES GOOGLE MAPS
## ====================================
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.**

## ====================================
## RÈGLES DIO (HTTP Client)
## ====================================
-keep class com.squareup.okhttp3.** { *; }
-keep interface com.squareup.okhttp3.** { *; }
-dontwarn com.squareup.okhttp3.**
-dontwarn okio.**

## ====================================
## RÈGLES GSON (si utilisé)
## ====================================
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## ====================================
## RÈGLES GÉNÉRIQUES
## ====================================
# Garder les annotations
-keepattributes *Annotation*

# Garder les numéros de ligne pour le debugging
-keepattributes SourceFile,LineNumberTable

# Garder les attributs génériques
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Garder les méthodes natives
-keepclasseswithmembernames class * {
    native <methods>;
}

# Garder les enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Garder les classes Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Garder les classes Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

## ====================================
## RÈGLES FIREBASE (si utilisé)
## ====================================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

## ====================================
## RÈGLES KEYCLOAK / OAUTH
## ====================================
# Si vous utilisez des bibliothèques d'authentification OAuth
-keep class net.openid.** { *; }
-dontwarn net.openid.**

## ====================================
## RÈGLES NOTIFICATIONS
## ====================================
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

## ====================================
## OPTIMISATIONS SUPPLÉMENTAIRES
## ====================================
# Optimiser et réduire le code
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Autoriser l'optimisation
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*

