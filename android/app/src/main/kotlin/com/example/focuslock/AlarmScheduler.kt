package com.example.focuslock

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Utility class for scheduling exact alarms via AlarmManager.
 */
object AlarmScheduler {

    private const val SERVICE_RESTART_REQUEST_CODE = 9001
    private const val MEME_ALARM_BASE_REQUEST_CODE = 5000

    /**
     * Schedule the foreground service to restart after a short delay.
     * Used when the service is killed but blocking is still active.
     */
    fun scheduleServiceRestart(context: Context) {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.example.focuslock.RESTART_SERVICE"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            SERVICE_RESTART_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val triggerTime = System.currentTimeMillis() + 5000 // 5 seconds delay

        setExactAlarm(alarmManager, triggerTime, pendingIntent)
    }

    /**
     * Schedule a meme alarm at a specific time (e.g., for force-stop detection).
     */
    fun scheduleMemeAlarm(
        context: Context,
        triggerTimeMillis: Long,
        requestCode: Int,
        memePath: String?,
        caption: String?
    ) {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.example.focuslock.MEME_ALARM"
            putExtra("meme_path", memePath ?: "")
            putExtra("caption", caption ?: "Get back to work!")
            putExtra("request_code", requestCode)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            MEME_ALARM_BASE_REQUEST_CODE + requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        setExactAlarm(alarmManager, triggerTimeMillis, pendingIntent)
    }

    /**
     * Cancel a previously scheduled meme alarm.
     */
    fun cancelMemeAlarm(context: Context, requestCode: Int) {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.example.focuslock.MEME_ALARM"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            MEME_ALARM_BASE_REQUEST_CODE + requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
    }

    /**
     * Set an exact alarm that works across all API levels.
     */
    private fun setExactAlarm(
        alarmManager: AlarmManager,
        triggerTimeMillis: Long,
        pendingIntent: PendingIntent
    ) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTimeMillis,
                        pendingIntent
                    )
                } else {
                    // Fallback: use inexact alarm
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTimeMillis,
                        pendingIntent
                    )
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMillis,
                    pendingIntent
                )
            }
        } catch (e: SecurityException) {
            // Fallback if permission denied
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTimeMillis,
                pendingIntent
            )
        }
    }
}
