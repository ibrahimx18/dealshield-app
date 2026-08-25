# SafePay ProGuard Rules
# Keep Flutter engine classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep shared_preferences (used for token storage)
-keep class androidx.security.** { *; }

# Keep model classes (needed for JSON serialization)
-keep class com.safepay.safepay_app.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# OkHttp (used by http package)
-dontwarn okhttp3.**
-dontwarn okio.**

# Play Store deferred components (Flutter engine references these)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
