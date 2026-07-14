package com.reforgestudios.reforge

import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import android.os.Bundle
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.LocationSettingsStatusCodes
import com.google.android.gms.location.Priority
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val LOCATION_READINESS_CHANNEL = "com.reforgestudios.reforge/location_readiness"
        private const val ENSURE_HIGH_ACCURACY = "ensureHighAccuracyEnabled"
        private const val LOCATION_SETTINGS_REQUEST_CODE = 8912
    }

    private var pendingLocationReadinessResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startService(Intent(this, CloseAppService::class.java))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_READINESS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    ENSURE_HIGH_ACCURACY -> ensureHighAccuracyEnabled(result)
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != LOCATION_SETTINGS_REQUEST_CODE) return

        if (resultCode == Activity.RESULT_OK) {
            checkHighAccuracySettings()
        } else {
            completeLocationReadiness(false)
        }
    }

    private fun ensureHighAccuracyEnabled(result: MethodChannel.Result) {
        if (pendingLocationReadinessResult != null) {
            result.error("request_in_progress", "Location settings resolution is already in progress.", null)
            return
        }

        pendingLocationReadinessResult = result
        checkHighAccuracySettings()
    }

    private fun checkHighAccuracySettings() {
        val locationRequest = LocationRequest.Builder(1_000L)
            .setPriority(Priority.PRIORITY_HIGH_ACCURACY)
            .build()
        val settingsRequest = LocationSettingsRequest.Builder()
            .addLocationRequest(locationRequest)
            .setAlwaysShow(true)
            .build()

        LocationServices.getSettingsClient(this)
            .checkLocationSettings(settingsRequest)
            .addOnSuccessListener { completeLocationReadiness(true) }
            .addOnFailureListener { error ->
                val resolvableError = error as? ResolvableApiException
                if (resolvableError?.statusCode == LocationSettingsStatusCodes.RESOLUTION_REQUIRED) {
                    try {
                        resolvableError.startResolutionForResult(this, LOCATION_SETTINGS_REQUEST_CODE)
                    } catch (_: IntentSender.SendIntentException) {
                        completeLocationReadiness(false)
                    }
                } else {
                    completeLocationReadiness(false)
                }
            }
    }

    private fun completeLocationReadiness(isReady: Boolean) {
        pendingLocationReadinessResult?.success(isReady)
        pendingLocationReadinessResult = null
    }
}
