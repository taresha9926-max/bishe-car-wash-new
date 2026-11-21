package com.bishe.sentinel

import android.util.Log
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.concurrent.TimeUnit

object SupabaseClient {
    private const val TAG = "BisheSentinel"

    // Default configuration matching Bishe Car Wash live production backend
    const val DEFAULT_SUPABASE_URL = "https://siioobajphmwzwwarlrr.supabase.co"
    const val DEFAULT_ANON_KEY =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpaW9vYmFqcGhtd3p3d2FybHJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1OTA3MjksImV4cCI6MjEwODE2NjcyOX0.7ilkYS4N8m_b-uy3ExxnE-SJidumg-Zk8hkHP8CgD4U"
    const val DEFAULT_SECRET_TOKEN = "bishe_sentinel_sec_2026_x89"

    private val httpClient = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .build()

    private val jsonMediaType = "application/json; charset=utf-8".toMediaType()

    /**
     * Ingest bank SMS by calling Supabase RPC `ingest_bank_sms`.
     */
    fun ingestBankSms(
        rawSms: String,
        provider: String,
        supabaseUrl: String = DEFAULT_SUPABASE_URL,
        anonKey: String = DEFAULT_ANON_KEY,
        secretToken: String = DEFAULT_SECRET_TOKEN,
        callback: (Boolean, String?) -> Unit
    ) {
        try {
            val url = "$supabaseUrl/rest/v1/rpc/ingest_bank_sms"
            val payload = JSONObject().apply {
                put("p_raw_sms", rawSms)
                put("p_provider", provider)
                put("p_secret_token", secretToken)
            }

            val requestBody = payload.toString().toRequestBody(jsonMediaType)
            val request = Request.Builder()
                .url(url)
                .header("apikey", anonKey)
                .header("Authorization", "Bearer $anonKey")
                .header("Content-Type", "application/json")
                .post(requestBody)
                .build()

            httpClient.newCall(request).enqueue(object : okhttp3.Callback {
                override fun onFailure(call: okhttp3.Call, e: java.io.IOException) {
                    val msg = if (e is java.net.UnknownHostException) {
                        "No Internet access on phone! Check Mobile Data or Wi-Fi."
                    } else {
                        e.message ?: "Network error"
                    }
                    Log.e(TAG, "Failed to send bank SMS to Supabase: $msg", e)
                    callback(false, msg)
                }

                override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                    val body = response.body?.string()
                    val isSuccess = response.isSuccessful
                    Log.i(TAG, "Supabase ingest_bank_sms response [${response.code}]: $body")
                    callback(isSuccess, body)
                }
            })
        } catch (e: Exception) {
            Log.e(TAG, "Exception during ingestBankSms: ${e.message}", e)
            callback(false, e.message)
        }
    }

    /**
     * Report Sentinel heartbeat (battery + online status) to Supabase RPC `update_sentinel_heartbeat`.
     */
    fun sendHeartbeat(
        batteryLevel: Int,
        status: String = "online",
        supabaseUrl: String = DEFAULT_SUPABASE_URL,
        anonKey: String = DEFAULT_ANON_KEY,
        secretToken: String = DEFAULT_SECRET_TOKEN,
        callback: ((Boolean) -> Unit)? = null
    ) {
        try {
            val url = "$supabaseUrl/rest/v1/rpc/update_sentinel_heartbeat"
            val payload = JSONObject().apply {
                put("p_battery", batteryLevel)
                put("p_status", status)
                put("p_secret_token", secretToken)
            }

            val requestBody = payload.toString().toRequestBody(jsonMediaType)
            val request = Request.Builder()
                .url(url)
                .header("apikey", anonKey)
                .header("Authorization", "Bearer $anonKey")
                .header("Content-Type", "application/json")
                .post(requestBody)
                .build()

            httpClient.newCall(request).enqueue(object : okhttp3.Callback {
                override fun onFailure(call: okhttp3.Call, e: java.io.IOException) {
                    Log.e(TAG, "Heartbeat error: ${e.message}")
                    callback?.invoke(false)
                }

                override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                    Log.d(TAG, "Heartbeat ok [${response.code}]")
                    callback?.invoke(response.isSuccessful)
                }
            })
        } catch (e: Exception) {
            Log.e(TAG, "Heartbeat exception: ${e.message}")
            callback?.invoke(false)
        }
    }
}
