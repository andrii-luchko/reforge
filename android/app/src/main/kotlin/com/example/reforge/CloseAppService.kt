package com.reforgestudios.reforge

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.Process

class CloseAppService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)

        try {
            stopService(Intent(this, Class.forName("id.flutter.flutter_background_service.BackgroundService")))
        } catch (e: Exception) {
            e.printStackTrace()
        }


        Process.killProcess(Process.myPid())
        System.exit(0)
    }
}