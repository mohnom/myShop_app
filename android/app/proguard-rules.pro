# Play Core optional deferred components referenced by Flutter engine
-dontwarn com.google.android.play.core.**

# Keep annotations
-keep @androidx.annotation.Keep class * { *; }

# Flutter Local Notifications & Gson TypeToken (prevents release crash)
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature, InnerClasses, EnclosingMethod, RuntimeVisibleAnnotations

# Firebase & Google Play Services
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Audioplayers & Entrig
-dontwarn com.entrig.**
-dontwarn java.awt.**
-dontwarn org.slf4j.**
