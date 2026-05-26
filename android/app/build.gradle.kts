plugins {
    id("com.android.application")
    id("kotlin-android")
    // برای پشتیبانی از jvmToolchain اضافه شد
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.esalat_car"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // استفاده از jvmToolchain برای هماهنگ کردن اجباری نسخه جاوا در تمام پکیج‌ها
    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.example.esalat_car"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}