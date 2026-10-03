# Keep Stripe SDK classes (Fix for R8 missing class issue)
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Keep React Native Stripe SDK classes
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn kotlinx.parcelize.Parceler$DefaultImpls
-dontwarn kotlinx.parcelize.Parceler
-dontwarn kotlinx.parcelize.Parcelize
# Keep Stripe classes
-keep class com.stripe.** { *; }
# General keep rules for Flutter plugins
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
