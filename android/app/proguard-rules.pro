# Flutter wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }

# Keep Firebase and Google Play Services classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Gson model classes
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# For Retrofit / OkHttp (if used)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# Keep models used for JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Flutter generated plugins
-keep class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin

# --- Fix missing Play Core classes (SplitInstall / SplitCompat) ---
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep Flutter Play Store Split classes (used internally)
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager { *; }

# Prevent warnings for missing SplitInstall dependencies
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
