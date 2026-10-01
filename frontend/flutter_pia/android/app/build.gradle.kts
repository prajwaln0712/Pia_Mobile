import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Single-sources the Auth0 domain from the same .env the Dart code reads, so the
// RedirectActivity intent-filter host can never drift from Auth0's client config.
val envProperties = Properties().apply {
    val envFile = rootProject.file("../.env")
    if (envFile.exists()) {
        envFile.inputStream().use { load(it) }
    }
}

fun requireEnv(key: String): String =
    envProperties.getProperty(key)?.takeIf { it.isNotBlank() }
        ?: throw GradleException("Missing $key in .env — copy .env.example to .env and fill it in.")

// Release signing. key.properties is gitignored and absent on most machines, so
// debug builds must keep working without it; only a release build demands it.
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        keystoreFile.inputStream().use { load(it) }
    }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "org.creatingwings.pia"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "org.creatingwings.pia"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["auth0Domain"] = requireEnv("AUTH0_DOMAIN")
        manifestPlaceholders["auth0Scheme"] = "org.creatingwings.pia"
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Never fall back to debug keys — a debug-signed artifact cannot be
            // published, and silently producing one wastes an upload attempt.
            signingConfig = if (hasReleaseKeystore) signingConfigs.getByName("release") else null
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Configuration runs for every build, so the missing-keystore check has to wait
// until the task graph is known — otherwise it would break debug builds too.
gradle.taskGraph.whenReady {
    if (!hasReleaseKeystore && allTasks.any { it.name.contains("Release") }) {
        throw GradleException(
            "No android/key.properties found. Copy android/key.properties.example, " +
                "create the keystore with keytool, and fill it in before building a release."
        )
    }
}
