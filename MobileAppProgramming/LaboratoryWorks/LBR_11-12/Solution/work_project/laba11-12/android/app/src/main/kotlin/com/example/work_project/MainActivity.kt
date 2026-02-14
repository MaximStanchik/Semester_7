package com.example.work_project

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.bluetooth.BluetoothAdapter
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL_COMMON = "demo.flutter/platform"
    private val CHANNEL_BATTERY_ANDROID = "demo.flutter/battery_android"
    private val CHANNEL_BATTERY_IOS = "demo.flutter/battery_ios"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_BATTERY_ANDROID).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_COMMON).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBluetoothStatus" -> {
                    try {
                        val btAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
                        val enabled = btAdapter?.isEnabled ?: false
                        result.success(enabled)
                    } catch (e: Exception) {
                        result.error("ERROR", e.localizedMessage, null)
                    }
                }

                "launchBrowser" -> {
                    val args = call.arguments as? Map<String, String>
                    val url = args?.get("url") ?: ""
                    if (url.isNotEmpty()) {
                        launchBrowser(url)
                        result.success(true)
                    } else {
                        result.error("BAD_ARGS", "URL is empty", null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_BATTERY_IOS).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        return try {
            val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val level = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                if (level >= 0) level else -1
            } else {
                -1
            }
        } catch (e: Exception) {
            -1
        }
    }

    private fun launchBrowser(url: String) {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse(url)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}
