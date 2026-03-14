plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.aviatordemo"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.aviatordemo"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    lint {
        xmlReport = true
        htmlReport = true
        abortOnError = false
    }
}

dependencies {
    testImplementation("junit:junit:4.13.2")
    implementation("com.squareup.okhttp3:okhttp:3.12.0")
    implementation("com.google.code.gson:gson:2.8.5")
}
