# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ForegroundService { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# TimeZone & ThreeTen
-keep class com.jakewharton.threetenabp.** { *; }
-keep class org.threeten.bp.** { *; }
-dontwarn org.threeten.bp.**

# Gson / Firebase (if obfuscated)
-keepattributes *Annotation*
-keepattributes Signature
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Flutter embedding & notifications support
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Core & Deferred Components (R8 Fix)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

