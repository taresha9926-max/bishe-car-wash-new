package com.bishe.sentinel

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class SentinelService : Service() {

    companion object {
        private const val TAG = "BisheSentinelService"
        private const val CHANNEL_ID = "bishe_sentinel_channel"
        private const val NOTIFICATION_ID = 202611
        private const val HEARTBEAT_INTERVAL_MS = 5 * 60 * 1000L // 5 minutes
    }

    private var wakeLock: PowerManager.WakeLock? = null
    private val serviceScope = CoroutineScope(Dispatchers.IO + Job())
    private var heartbeatJob: Job? = null

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "Bishe Sentinel Service created.")
        createNotificationChannel()
        acquireWakeLock()
        startHeartbeatLoop()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildForegroundNotification()
        startForeground(NOTIFICATION_ID, notification)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        heartbeatJob?.cancel()
        releaseWakeLock()
        Log.i(TAG, "Bishe Sentinel Service destroyed.")
    }

    private fun acquireWakeLock() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "BisheSentinel::KeepAliveWakeLock"
            ).apply {
                acquire()
            }
            Log.i(TAG, "Partial WakeLock acquired.")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to acquire WakeLock: ${e.message}")
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
                Log.i(TAG, "Partial WakeLock released.")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing WakeLock: ${e.message}")
        }
    }

    private fun startHeartbeatLoop() {
        heartbeatJob = serviceScope.launch {
            while (isActive) {
                try {
                    val battery = getBatteryLevel()
                    Log.i(TAG, "Reporting heartbeat to Supabase (Battery: $battery%)...")
                    SupabaseClient.sendHeartbeat(
                        batteryLevel = battery,
                        status = "online"
                    )
                } catch (e: Exception) {
                    Log.e(TAG, "Error during heartbeat cycle: ${e.message}")
                }
                delay(HEARTBEAT_INTERVAL_MS)
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryStatus: Intent? = registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )
        val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        return if (level >= 0 && scale > 0) {
            ((level / scale.toFloat()) * 100).toInt()
        } else {
            100
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Bishe PayGuard Sentinel Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps Bishe Sentinel listening for incoming CBE and Telebirr SMS alerts"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Bishe PayGuard: Online 🟢")
            .setContentText("Monitoring Incoming CBE & Telebirr Payments...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}
