plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.here"
    // Updated to 35 to match your plugin requirements
    compileSdk = 35 
    // Updated to match your Firebase NDK requirement from logs
    ndkVersion = "27.0.12077973" 

    signingConfigs {
        create("release") {
            // This points to the permanent key you uploaded to GitHub
            storeFile = file("permanent-key.jks")
            storePassword = "YOUR_PASSWORD_HERE" // Put your Cloud Shell password here
            keyAlias = "my-alias"
            keyPassword = "YOUR_PASSWORD_HERE" // Put your Cloud Shell password here
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
        
        // FIXED: Firebase Auth 24+ requires minSdk 23 (Android 6.0)
        minSdk = 23 
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Changed from "debug" to "release" to use your permanent key
            signingConfig = signingConfigs.getByName("release")
            
            // Standard release optimizations
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
    // Firebase BoM for compatible versions
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
}
