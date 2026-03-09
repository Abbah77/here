plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // REMOVE THIS LINE: id("com.google.gms.google-services")
}

android {
    namespace = "com.example.here"
    compileSdk = 35 
    ndkVersion = "27.0.12077973" 

    signingConfigs {
        create("release") {
            // This pulls the file path from the "Android Code Signing" tab
            val keystorePath = System.getenv("CM_KEYSTORE_PATH")
            
            if (!keystorePath.isNullOrEmpty()) {
                storeFile = file(keystorePath)
                // These pull the passwords you just typed into the Code Signing tab
                storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("CM_KEY_ALIAS")
                keyPassword = System.getenv("CM_KEY_PASSWORD")
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
        minSdk = 23 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Tell the app to use the "release" config we defined above
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

// REMOVE ALL FIREBASE DEPENDENCIES BELOW
// Delete this entire dependencies block:
// dependencies {
//     implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
//     implementation("com.google.firebase:firebase-analytics")
//     implementation("com.google.firebase:firebase-auth")
//     implementation("com.google.firebase:firebase-firestore")
//     implementation("com.google.firebase:firebase-storage")
// }
