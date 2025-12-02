# Flutter Secure Storage
-keepclasseswithmembernames class * {
    native <methods>;
}

-keep class androidx.security.crypto.** { *; }
-keep interface androidx.security.crypto.** { *; }

# Keep the SecureStorageService class
-keep class com.skybertech.charity_trust.** { *; }
