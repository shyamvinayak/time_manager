package com.example.time_manager

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.widget.Toast
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.*

class TestService : Service() {

    // declaring Handler
    private val handler = Handler(Looper.getMainLooper())

    // Runnable to show current time
    private val timeRunnable = object : Runnable {
        override fun run() {
            // get current time
            val currentTime = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
            // show current time
            Toast.makeText(applicationContext, "Current Time: $currentTime", Toast.LENGTH_SHORT).show()
            // schedule next execution
            handler.postDelayed(this, 60000) // 1 minute delay
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Start the service in the foreground to keep it running in the background
        startForegroundService()

        // start showing current time
        handler.post(timeRunnable)

        // returns the status
        // of the program
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Toast.makeText(applicationContext, "Service stopped...", Toast.LENGTH_LONG).show()
        // stop showing current time
        handler.removeCallbacks(timeRunnable)
    }

    override fun onBind(intent: Intent): IBinder {
        throw UnsupportedOperationException("Not yet implemented")
    }

    private fun startForegroundService() {
        val channelId = "TimeServiceChannel"
        val channelName = "Time Service Channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE)

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Time Service")
            .setContentText("The service is running in the background")
            .setSmallIcon(R.drawable.ic_bg_service_small)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)
    }
}
