# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }

# Keep ProGuard annotations
-dontwarn proguard.annotation.**
-keep class proguard.annotation.** { *; }

# Also add any rules from missing_rules.txt
# You can copy those rules from build/app/outputs/mapping/release/missing_rules.txt