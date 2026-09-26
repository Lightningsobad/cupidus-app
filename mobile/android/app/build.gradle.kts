plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Processes google-services.json into resources. google_sign_in 7.x reads
    // the generated `default_web_client_id` as its Android serverClientId.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.snapsofts.cupid_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications 22.x, which backports
        // java.time to older Android for scheduled notifications.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.snapsofts.cupid"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Selects the backend the build talks to. Deliberately no
    // applicationIdSuffix/versionNameSuffix: google-services.json registers only
    // com.snapsofts.cupid, and suffixing breaks Google Sign-In (BUG-20260823-001).
    // The flavor name reaches Dart as `appFlavor` via Flutter's built-in
    // FLUTTER_APP_FLAVOR propagation; see lib/core/config/cupid_api_config.dart.
    flavorDimensions += "backend"

    productFlavors {
        create("local") {
            dimension = "backend"
        }
        create("prod") {
            dimension = "backend"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Version pinned to match flutter_local_notifications' own android/build.gradle.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
