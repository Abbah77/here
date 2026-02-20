import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.here"
    compileSdk = 35 
    ndkVersion = "27.0.12077973" 

    signingConfigs {
        create("release") {
            val keystoreBase64 = System.getenv("KEYSTORE_BASE64")
            // We save it to a temporary location on the Codemagic build machine
            val keystoreFile = file("${project.buildDir}/temporary_keystore.jks")

            if (!keystoreBase64.isNullOrEmpty()) {
                try {
                    // MimeDecoder is more robust against formatting issues
                    val decodedBytes = Base64.getMimeDecoder().decode(keystoreBase64.trim())
                    keystoreFile.writeBytes(decodedBytes)
                    
                    storeFile = keystoreFile
                    // Replace these with your actual passwords
                    storePassword = "Mummyyyy" 
                    keyAlias = "my-alias"
                    keyPassword = "Mummyyyy"
                } catch (e: Exception) {
                    throw GradleException("Keystore decoding failed. Check your KEYSTORE_BASE64 variable.")
                }
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.here"
        // Required for modern Firebase Auth
        minSdk = 23 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Standard Firebase dependencies
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
}
