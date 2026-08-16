package com.duckitlabs.bebeapp

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.duckitlabs.bebeapp/notification_permission"
    private val preferenceName = "bebeapp_notification_permission"
    private val requestedKey = "requested"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(notificationPermissionStatus())
                    "markRequested" -> {
                        getSharedPreferences(preferenceName, MODE_PRIVATE)
                            .edit()
                            .putBoolean(requestedKey, true)
                            .apply()
                        result.success(null)
                    }
                    "openSettings" -> result.success(openNotificationSettings())
                    else -> result.notImplemented()
                }
            }
    }

    private fun notificationPermissionStatus(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return "granted"
        }
        if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            return "granted"
        }
        val wasRequested = getSharedPreferences(preferenceName, MODE_PRIVATE)
            .getBoolean(requestedKey, false)
        if (!wasRequested) return "notDetermined"
        return if (
            ActivityCompat.shouldShowRequestPermissionRationale(
                this,
                Manifest.permission.POST_NOTIFICATIONS,
            )
        ) {
            "denied"
        } else {
            "permanentlyDenied"
        }
    }

    private fun openNotificationSettings(): Boolean = try {
        startActivity(
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            },
        )
        true
    } catch (_: Exception) {
        false
    }
}
