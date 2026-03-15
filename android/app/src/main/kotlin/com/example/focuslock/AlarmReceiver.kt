package com.example.focuslock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Receives alarm broadcasts and either restarts the service or launches the AlarmActivity.
 */
class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            "com.example.focuslock.RESTART_SERVICE" -> {
                // Restart the foreground service
                FocusLockForegroundService.start(context)
            }
            "com.example.focuslock.MEME_ALARM" -> {
                // Launch the full-screen alarm activity with meme
                val memePath = intent.getStringExtra("meme_path") ?: ""
                val caption = intent.getStringExtra("caption") ?: "Get back to work!"

                val activityIntent = Intent(context, AlarmActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP
                    putExtra("meme_path", memePath)
                    putExtra("caption", caption)
                }
                context.startActivity(activityIntent)
            }
        }
    }
}
