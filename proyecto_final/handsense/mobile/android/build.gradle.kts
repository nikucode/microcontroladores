import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// reactive_ble_mobile 5.5.0 declara compileSdk 33, pero sus dependencias
// AndroidX actuales requieren 34 o superior. La aplicación ya se compila con
// SDK 36; igualamos únicamente este módulo sin modificar el caché de Pub.
subprojects {
    if (name == "reactive_ble_mobile") {
        afterEvaluate {
            extensions.configure<LibraryExtension> {
                compileSdk = 36
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
