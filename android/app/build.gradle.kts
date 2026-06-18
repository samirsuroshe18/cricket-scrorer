plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cricket_scorer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.cricket_scorer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "cricket_scorer"

    productFlavors {
        create("prod") {
            dimension = "cricket_scorer";
            resValue(
                type = "string",
                name = "app_name",
                value = "Cricket Scorer"
            )
            applicationIdSuffix = ""
            signingConfig = signingConfigs.getByName("debug")
        }
        create("uat") {
            dimension = "cricket_scorer"
            resValue(
                type = "string",
                name = "app_name",
                value = "Cricket Scorer-uat"
            )
            applicationIdSuffix = ".uat"
            signingConfig = signingConfigs.getByName("debug")
        }
        create("dev") {
            dimension = "cricket_scorer"
            resValue(
                type = "string",
                name = "app_name",
                value = "Cricket Scorer-dev"
            )
            applicationIdSuffix = ".dev"
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = null
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
