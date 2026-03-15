package com.example.focuslock

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Main activity that hosts Flutter and sets up platform channels
 * for communication between Flutter and native Android code.
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val BLOCKING_CHANNEL = "focuslock/blocking"
        private const val SERVICE_CHANNEL = "focuslock/service"
        private const val ALARM_CHANNEL = "focuslock/alarm"
        private const val EVENTS_CHANNEL = "focuslock/blocked_events"
        private const val PREFS_NAME = "focuslock_prefs"
    }

    private lateinit var prefs: SharedPreferences
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private var pollingRunnable: Runnable? = null
    private var lastEventData: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        setupBlockingChannel(flutterEngine)
        setupServiceChannel(flutterEngine)
        setupAlarmChannel(flutterEngine)
        setupEventChannel(flutterEngine)
    }

    /**
     * Channel for app blocking operations.
     */
    private fun setupBlockingChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BLOCKING_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startBlocking" -> {
                        val packages = call.argument<List<String>>("packages") ?: emptyList()
                        val packagesString = packages.joinToString(",")
                        prefs.edit()
                            .putString(FocusLockAccessibilityService.BLOCKED_APPS_KEY, packagesString)
                            .putBoolean(FocusLockAccessibilityService.BLOCKING_ACTIVE_KEY, true)
                            .putBoolean("blocking_active", true)
                            .apply()
                        result.success(true)
                    }
                    "stopBlocking" -> {
                        prefs.edit()
                            .putBoolean(FocusLockAccessibilityService.BLOCKING_ACTIVE_KEY, false)
                            .putBoolean("blocking_active", false)
                            .apply()
                        result.success(true)
                    }
                    "isBlockingActive" -> {
                        val active = prefs.getBoolean(
                            FocusLockAccessibilityService.BLOCKING_ACTIVE_KEY, false
                        )
                        result.success(active)
                    }
                    "isAccessibilityServiceEnabled" -> {
                        val enabled = FocusLockAccessibilityService
                            .isAccessibilityServiceEnabled(this)
                        result.success(enabled)
                    }
                    "openAccessibilitySettings" -> {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Channel for foreground service operations.
     */
    private fun setupServiceChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SERVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startForegroundService" -> {
                        try {
                            FocusLockForegroundService.start(this)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SERVICE_ERROR", e.message, null)
                        }
                    }
                    "stopForegroundService" -> {
                        FocusLockForegroundService.stop(this)
                        result.success(true)
                    }
                    "isServiceRunning" -> {
                        val running = FocusLockForegroundService.isRunning(this)
                        result.success(running)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Channel for alarm operations.
     */
    private fun setupAlarmChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        val triggerTime = call.argument<Long>("triggerTime") ?: 0L
                        val memePath = call.argument<String>("memePath") ?: ""
                        val caption = call.argument<String>("caption") ?: "Get back to work!"
                        val requestCode = call.argument<Int>("requestCode") ?: 0

                        AlarmScheduler.scheduleMemeAlarm(
                            this, triggerTime, requestCode, memePath, caption
                        )
                        result.success(true)
                    }
                    "cancelAlarm" -> {
                        val requestCode = call.argument<Int>("requestCode") ?: 0
                        AlarmScheduler.cancelMemeAlarm(this, requestCode)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * EventChannel to stream blocked app events from native to Flutter.
     * Polls SharedPreferences for events from the AccessibilityService.
     */
    private fun setupEventChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTS_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startPolling()
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    stopPolling()
                }
            })
    }

    /**
     * Polls SharedPreferences every 500ms to check for new blocked events
     * from the AccessibilityService and forwards them to Flutter.
     */
    private fun startPolling() {
        pollingRunnable = object : Runnable {
            override fun run() {
                val eventData = prefs.getString(
                    FocusLockAccessibilityService.LAST_BLOCKED_EVENT_KEY, null
                )
                if (eventData != null && eventData != lastEventData) {
                    lastEventData = eventData
                    val parts = eventData.split("|")
                    if (parts.size == 2) {
                        val data = mapOf(
                            "packageName" to parts[0],
                            "timestamp" to parts[1].toLongOrNull()
                        )
                        eventSink?.success(data)
                    }
                }
                handler.postDelayed(this, 500)
            }
        }
        handler.post(pollingRunnable!!)
    }

    private fun stopPolling() {
        pollingRunnable?.let { handler.removeCallbacks(it) }
        pollingRunnable = null
    }

    override fun onDestroy() {
        stopPolling()
        super.onDestroy()
    }
}
