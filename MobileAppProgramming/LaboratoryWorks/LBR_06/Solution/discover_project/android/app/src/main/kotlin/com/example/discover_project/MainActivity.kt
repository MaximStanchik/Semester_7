package com.example.discover_project

import android.content.Intent
import android.os.BatteryManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*
import android.provider.AlarmClock
import android.content.IntentFilter

class MainActivity: FlutterActivity() {
    private val BATTERY_CHANNEL = "samples.flutter.dev/battery"
    private val ALARM_CHANNEL = "samples.flutter.dev/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available.", null)
                    }
                }
                "isCharging" -> {
                    val isCharging = isDeviceCharging()
                    result.success(isCharging)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setAlarm") {
                val time = call.argument<String>("time")
                if (time != null) {
                    setAlarm(time, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Time expected", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun isDeviceCharging(): Boolean {
        val batteryStatus = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val chargePlug = batteryStatus?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1
        val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
        val isPlugged = chargePlug == BatteryManager.BATTERY_PLUGGED_AC ||
                chargePlug == BatteryManager.BATTERY_PLUGGED_USB ||
                chargePlug == BatteryManager.BATTERY_PLUGGED_WIRELESS
        return isCharging || isPlugged
    }
    // Установка будильника через Intent
    private fun setAlarm(time: String, result: MethodChannel.Result) {
        val intent = Intent(AlarmClock.ACTION_SET_ALARM)
        intent.putExtra(AlarmClock.EXTRA_MESSAGE, "Будильник из Flutter")
        val parts = time.split(":")
        if (parts.size == 2) {
            intent.putExtra(AlarmClock.EXTRA_HOUR, parts[0].toIntOrNull() ?: 7)
            intent.putExtra(AlarmClock.EXTRA_MINUTES, parts[1].toIntOrNull() ?: 0)
        }
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        try {
            startActivity(intent)
            result.success("Запуск будильника: $time")
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Требуется разрешение SET_ALARM", null)
        } catch (e: Exception) {
            result.error("ALARM_ERROR", e.localizedMessage, null)
        }
    }
}
