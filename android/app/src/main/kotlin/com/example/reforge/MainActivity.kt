package com.reforgestudios.reforge

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    /**
     * Called when the user removes this app's task from the recent apps list
     * (i.e. swipes the card away). On Android, a Foreground Service normally
     * survives this action by design. We override this to explicitly stop our
     * background tracking service so that iOS and Android behave identically:
     * killing the UI also kills the tracker.
     *
     * Note: This is NOT called when Android kills the process due to memory
     * pressure — that is handled separately via the service's own lifecycle.
     */
    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        stopService(
            Intent(this, id.flutter.flutter_background_service.BackgroundService::class.java)
        )
    }
}
