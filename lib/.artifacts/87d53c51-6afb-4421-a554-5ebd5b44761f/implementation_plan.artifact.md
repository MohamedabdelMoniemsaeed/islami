# Implementation Plan - Upgrade Android Build Toolchain

This plan addresses the build failure and deprecation warnings by upgrading Gradle, the Android Gradle Plugin (AGP), and the Kotlin Gradle Plugin (KGP) to the versions recommended by the Flutter tool.

## User Review Required

> [!IMPORTANT]
> This involves upgrading core build components. If the build continues to fail with "Unresolved reference 'io'", we may need to manually verify the Flutter SDK integration in the `app/build.gradle` file.

## Proposed Changes

### Android Build Configuration
#### [MODIFY] [gradle-wrapper.properties](file:///C:/Pro Flutter/islami/android/gradle/wrapper/gradle-wrapper.properties)
- Upgrade `distributionUrl` to use Gradle **8.14.0**.

#### [MODIFY] [settings.gradle](file:///C:/Pro Flutter/islami/android/settings.gradle)
- Upgrade `com.android.application` to version **8.11.1**.
- Upgrade `org.jetbrains.kotlin.android` to version **2.2.20**.

#### [MODIFY] [app/build.gradle](file:///C:/Pro Flutter/islami/android/app/build.gradle)
- Ensure `compileSdkVersion` and `targetSdkVersion` are at least **34** (required for newer AGP versions).
- Update `jvmTarget` to `'17'` as newer Kotlin/AGP versions require JDK 17.

## Verification Plan

### Manual Verification
- Run `flutter clean`.
- Run `flutter build appbundle --release` to verify the compilation error `Unresolved reference 'io'` is resolved.
- Run `shorebird release android --artifact apk` to verify Shorebird integration.

### Automated Tests
- `flutter analyze` to ensure project health.
