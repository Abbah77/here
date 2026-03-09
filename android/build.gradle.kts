// Root-level build.gradle.kts
plugins {
    // 1. Core Android plugin - Required for any Android app
    id("com.android.application") version "8.11.1" apply false
    
    // 2. Kotlin plugin - Required for Flutter's Android side
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/**
 * Customizing build directories: 
 * This moves the build folder out of the project root to keep the structure clean.
 */
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Ensures the ':app' project is evaluated first to prevent configuration errors
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
