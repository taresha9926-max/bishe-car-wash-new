package com.bishe.sentinel

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : AppCompatActivity() {

    private lateinit var statusText: TextView
    private lateinit var btnToggleService: Button
    private lateinit var btnBatteryOpt: Button
    private lateinit var infoText: TextView

    companion object {
        private const val PERMISSION_REQUEST_CODE = 101
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        statusText = findViewById(R.id.tvStatus)
        btnToggleService = findViewById(R.id.btnToggleService)
        btnBatteryOpt = findViewById(R.id.btnBatteryOpt)
        infoText = findViewById(R.id.tvInfo)

        checkAndRequestPermissions()

        btnToggleService.setOnClickListener {
            startSentinelService()
        }

        btnBatteryOpt.setOnClickListener {
            requestIgnoreBatteryOptimizations()
        }

        updateUiStatus(true)
    }

    private fun checkAndRequestPermissions() {
        val permissions = mutableListOf(
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }

        val missing = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (missing.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, missing.toTypedArray(), PERMISSION_REQUEST_CODE)
        } else {
            startSentinelService()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                Toast.makeText(this, "Permissions granted! Starting Sentinel...", Toast.LENGTH_SHORT).show()
                startSentinelService()
            } else {
                Toast.makeText(this, "SMS permissions are required to capture bank payments.", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun startSentinelService() {
        val intent = Intent(this, SentinelService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        updateUiStatus(true)
        Toast.makeText(this, "Bishe Sentinel is actively monitoring!", Toast.LENGTH_SHORT).show()
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                }
                startActivity(intent)
            } else {
                Toast.makeText(this, "Battery optimization is already unrestricted!", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun isNetworkConnected(): Boolean {
        val cm = getSystemService(android.content.Context.CONNECTIVITY_SERVICE) as? android.net.ConnectivityManager ?: return false
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val net = cm.activeNetwork ?: return false
            val cap = cm.getNetworkCapabilities(net) ?: return false
            cap.hasCapability(android.net.NetworkCapabilities.NET_CAPABILITY_INTERNET)
        } else {
            @Suppress("DEPRECATION")
            val netInfo = cm.activeNetworkInfo
            @Suppress("DEPRECATION")
            netInfo != null && netInfo.isConnected
        }
    }

    private fun updateUiStatus(isRunning: Boolean) {
        if (isRunning) {
            statusText.text = "BISHE PAYGUARD: ACTIVE 🟢"
            statusText.setTextColor(0xFF10B981.toInt())
            infoText.text = "Connected to Supabase.\nMonitoring CBE & Telebirr SIM alerts."
        } else {
            statusText.text = "BISHE PAYGUARD: STOPPED 🔴"
            statusText.setTextColor(0xFFEF4444.toInt())
        }
    }
}
