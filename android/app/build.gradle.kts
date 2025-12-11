import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sportsdotcom.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.sportsdotcom.app"  // TREBUIE să fie EXACT ID-ul din Google Play
        minSdk = 21
        targetSdk = 34
        versionCode = 11      // > decât ce e acum live
        versionName = "1.1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["STORE_FILE"]?.toString()
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
            storePassword = keystoreProperties["STORE_PASSWORD"]?.toString()
            keyAlias = keystoreProperties["KEY_ALIAS"]?.toString()
            keyPassword = keystoreProperties["KEY_PASSWORD"]?.toString()
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true

            // Dacă vrei și resource shrinking (foarte probabil da):
            isShrinkResources = true

            // Fişierele de ProGuard/R8 (template standard Flutter)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
