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
            // Reconstruct the keystore file from the Environment Variable
            val keystoreBase64 = System.getenv("KEYSTORE_BASE64")?.trim()
            val keystoreFile = file("permanent-key-decoded.jks")
            
            if (keystoreBase64 != null && keystoreBase64.isNotEmpty()) {
                // Decodes the string back into the binary file
                val decodedBytes = Base64.getDecoder().decode(keystoreBase64.trim())
                keystoreFile.writeBytes(decodedBytes)
                storeFile = keystoreFile
            } else {
                // Local fallback
                storeFile = file("permanent-key.jks")
            }

            // Replace with your actual password from Cloud Shell
            storePassword = "YOUR_PASSWORD_HERE" 
            keyAlias = "my-alias"
            keyPassword = "YOUR_PASSWORD_HERE"
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
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
}
