# Flutter Secure Storage
-keepclasseswithmembernames class * {
    native <methods>;
}

-keep class androidx.security.crypto.** { *; }
-keep interface androidx.security.crypto.** { *; }

# Keep the SecureStorageService class
-keep class com.annujoomconnect.** { *; }

# Razorpay
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }
-optimizations !method/inlining/
-keepclasseswithmembers class * {
    public void onPayment*(...);
}
