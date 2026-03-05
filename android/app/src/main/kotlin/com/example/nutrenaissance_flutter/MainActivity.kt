package com.nutrenaissance.flutter

import android.content.Intent
import androidx.health.connect.client.HealthConnectClient
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nutrenaissance/platform")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isHealthConnectAvailable" -> {
                        try {
                            val status = HealthConnectClient.getSdkStatus(this)
                            result.success(status == HealthConnectClient.SDK_AVAILABLE)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "openHealthConnect" -> {
                        try {
                            // Try to open the Health Connect app directly
                            val intent = packageManager.getLaunchIntentForPackage(
                                "com.google.android.apps.healthdata"
                            )
                            if (intent != null) {
                                startActivity(intent)
                                result.success(true)
                            } else {
                                // HC is installed but can't open — try the action intent
                                val actionIntent = Intent("androidx.health.ACTION_HEALTH_CONNECT_SETTINGS")
                                actionIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(actionIntent)
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
