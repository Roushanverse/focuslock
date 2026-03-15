package com.example.focuslock

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent

/**
 * Accessibility service that detects when a blocked app is opened
 * and performs GLOBAL_ACTION_BACK to close it.
 *
 * The list of blocked packages is read from SharedPreferences,
 * which is updated by Flutter via MethodChannel.
 */
class FocusLockAccessibilityService : AccessibilityService() {

    companion object {
        const val PREFS_NAME = "focuslock_prefs"
        const val BLOCKED_APPS_KEY = "blocked_apps"
        const val BLOCKING_ACTIVE_KEY = "blocking_active"
        const val LAST_BLOCKED_EVENT_KEY = "last_blocked_event"

        /**
         * Check if this accessibility service is enabled.
         */
        fun isAccessibilityServiceEnabled(context: Context): Boolean {
            val prefString = android.provider.Settings.Secure.getString(
                context.contentResolver,
                android.provider.Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false

            return prefString.contains(
                "${context.packageName}/${FocusLockAccessibilityService::class.java.canonicalName}"
            )
        }
    }

    private lateinit var prefs: SharedPreferences

    override fun onServiceConnected() {
        super.onServiceConnected()
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
            notificationTimeout = 100
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return

        // Skip system UI and our own app
        if (packageName == "com.example.focuslock" ||
            packageName == "com.android.systemui" ||
            packageName == "com.android.launcher" ||
            packageName.startsWith("com.android.launcher")
        ) return

        // Check if blocking is active
        val isBlockingActive = prefs.getBoolean(BLOCKING_ACTIVE_KEY, false)
        if (!isBlockingActive) return

        // Get the blocked apps list
        val blockedAppsString = prefs.getString(BLOCKED_APPS_KEY, "") ?: ""
        if (blockedAppsString.isEmpty()) return

        val blockedApps = blockedAppsString.split(",").map { it.trim() }.filter { it.isNotEmpty() }

        if (blockedApps.contains(packageName)) {
            // Block the app by pressing back
            performGlobalAction(GLOBAL_ACTION_BACK)

            // Store event info for Flutter to pick up
            val eventData = "${packageName}|${System.currentTimeMillis()}"
            prefs.edit().putString(LAST_BLOCKED_EVENT_KEY, eventData).apply()

            // Also go home for a stronger block
            performGlobalAction(GLOBAL_ACTION_HOME)
        }
    }

    override fun onInterrupt() {
        // Service interrupted
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
