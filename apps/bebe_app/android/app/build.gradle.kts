import groovy.json.JsonSlurper

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val developmentEnvironmentFile = rootProject.file(
    "../config/development.env.json",
)
check(developmentEnvironmentFile.isFile) {
    "Falta el archivo de entorno: ${developmentEnvironmentFile.path}"
}
val developmentEnvironment = JsonSlurper().parseText(
    developmentEnvironmentFile.readText(),
) as Map<*, *>
fun developmentEnvironmentValue(key: String): String =
    developmentEnvironment[key]?.toString()?.trim().orEmpty()

check(developmentEnvironmentValue("APP_ENVIRONMENT") == "development") {
    "development.env.json debe declarar APP_ENVIRONMENT=development"
}
check(developmentEnvironmentValue("APP_DISPLAY_NAME").isNotEmpty()) {
    "development.env.json debe declarar APP_DISPLAY_NAME"
}

android {
    namespace = "com.duckitlabs.bebeapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        resValues = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.duckitlabs.bebeapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    flavorDimensions += "environment"
    productFlavors {
        create("development") {
            dimension = "environment"
            // Se conserva el applicationId registrado en Firebase. Cuando se
            // registre una app Firebase de desarrollo, se podrá agregar el
            // sufijo junto con su google-services.json específico.
            versionNameSuffix = "-development"
            resValue(
                "string",
                "app_name",
                developmentEnvironmentValue("APP_DISPLAY_NAME"),
            )
            manifestPlaceholders["appEnvironment"] =
                developmentEnvironmentValue("APP_ENVIRONMENT")
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
