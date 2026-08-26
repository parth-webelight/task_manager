# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ForegroundService { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Gson & Generic Type Preservation (Critical for R8 / Release Build Notifications)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepclassmembers class * extends com.google.gson.reflect.TypeToken {
    <init>(...);
}

# TimeZone & ThreeTen
-keep class com.jakewharton.threetenabp.** { *; }
-keep class org.threeten.bp.** { *; }
-keep class timezone.** { *; }
-dontwarn org.threeten.bp.**
-dontwarn timezone.**

# Javascript Interface & Annotations
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Flutter embedding & notifications support
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# AndroidX Core & Broadcast Receivers
-keep class androidx.core.app.CoreComponentFactory { *; }
-keep class androidx.work.** { *; }

# Google Play Core & Deferred Components (R8 Fix)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

