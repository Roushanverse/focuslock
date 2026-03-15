package com.example.focuslock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Starts the ForegroundService on device boot to maintain blocking if active.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            // Check if blocking was active before reboot
            val prefs = context.getSharedPreferences("focuslock_prefs", Context.MODE_PRIVATE)
            val isBlockingActive = prefs.getBoolean("blocking_active", false)

            if (isBlockingActive) {
                FocusLockForegroundService.start(context)
            }
        }
    }
}
