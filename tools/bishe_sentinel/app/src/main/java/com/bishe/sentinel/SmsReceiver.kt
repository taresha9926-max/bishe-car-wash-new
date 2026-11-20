package com.bishe.sentinel

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BisheSentinelSms"

        // Telebirr short codes & senders in Ethiopia
        private val TELEBIRR_SENDERS = listOf("127", "telebirr", "ethio tel", "Ethio telecom")
        
        // CBE senders in Ethiopia
        private val CBE_SENDERS = listOf("cbe", "cbemb", "commercial bank", "cbebirr")
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        try {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            if (messages.isNullOrEmpty()) return

            val sender = messages[0].displayOriginatingAddress ?: ""
            val fullBody = messages.joinToString(separator = "") { it.displayMessageBody ?: "" }

            Log.i(TAG, "Incoming SMS from '$sender': $fullBody")

            val senderLower = sender.lowercase()
            val bodyLower = fullBody.lowercase()

            val isTelebirr = TELEBIRR_SENDERS.any { senderLower.contains(it) } ||
                    bodyLower.contains("telebirr") ||
                    bodyLower.contains("transaction number is")

            val isCbe = CBE_SENDERS.any { senderLower.contains(it) } ||
                    bodyLower.contains("banking with cbe") ||
                    bodyLower.contains("mbreciept.cbe.com.et") ||
                    bodyLower.contains("commercial bank of ethiopia")

            if (isTelebirr) {
                Log.i(TAG, "Detected Telebirr transaction SMS! Forwarding to Supabase...")
                SupabaseClient.ingestBankSms(
                    rawSms = fullBody,
                    provider = "telebirr"
                ) { success, msg ->
                    Log.i(TAG, "Telebirr ingestion result: success=$success, response=$msg")
                }
            } else if (isCbe) {
                Log.i(TAG, "Detected CBE transaction SMS! Forwarding to Supabase...")
                SupabaseClient.ingestBankSms(
                    rawSms = fullBody,
                    provider = "cbe"
                ) { success, msg ->
                    Log.i(TAG, "CBE ingestion result: success=$success, response=$msg")
                }
            } else {
                Log.d(TAG, "SMS ignored (not identified as Telebirr or CBE).")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error processing incoming SMS: ${e.message}", e)
        }
    }
}
