package com.example.focuslock

import android.app.Activity
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.*
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView

/**
 * Full-screen alarm activity that shows a meme/taunt when triggered.
 * Shows over lock screen, plays alarm sound, and vibrates.
 */
class AlarmActivity : Activity() {

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Show over lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }

        val caption = intent?.getStringExtra("caption") ?: "Get back to work!"

        // Build a simple layout programmatically
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(0xFF1A1A2E.toInt())
            setPadding(48, 48, 48, 48)
        }

        val titleText = TextView(this).apply {
            text = "⚠️ FOCUS LOCK ALERT ⚠️"
            textSize = 28f
            setTextColor(0xFFFF6B6B.toInt())
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 32)
        }

        val captionText = TextView(this).apply {
            text = caption
            textSize = 22f
            setTextColor(0xFFEEEEEE.toInt())
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 48)
        }

        val subtitleText = TextView(this).apply {
            text = "You tried to escape your focus session!\nGet back to work! 💪"
            textSize = 16f
            setTextColor(0xFFAAAAAA.toInt())
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 48)
        }

        val dismissButton = Button(this).apply {
            text = "I'll Focus Now"
            textSize = 18f
            setPadding(48, 24, 48, 24)
            setOnClickListener {
                stopAlarm()
                finish()
            }
        }

        layout.addView(titleText)
        layout.addView(captionText)
        layout.addView(subtitleText)
        layout.addView(dismissButton)

        val scrollView = ScrollView(this).apply {
            addView(layout)
        }

        setContentView(scrollView)

        // Start alarm sound and vibration
        startAlarm()
    }

    private fun startAlarm() {
        try {
            // Play alarm sound - use default alarm ringtone
            val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                setDataSource(this@AlarmActivity, alarmUri)
                isLooping = true
                prepare()
                start()
            }
        } catch (e: Exception) {
            // Silently handle - alarm sound is best-effort
        }

        try {
            // Vibrate
            vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager =
                    getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(VIBRATOR_SERVICE) as Vibrator
            }

            val pattern = longArrayOf(0, 500, 200, 500, 200, 500)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(
                    VibrationEffect.createWaveform(pattern, 0) // repeat from index 0
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
        } catch (e: Exception) {
            // Silently handle
        }
    }

    private fun stopAlarm() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) { /* ignore */ }

        try {
            vibrator?.cancel()
            vibrator = null
        } catch (e: Exception) { /* ignore */ }
    }

    override fun onDestroy() {
        stopAlarm()
        super.onDestroy()
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Prevent dismissing with back button - user must tap the button
    }
}
