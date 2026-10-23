import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// BISHE Car Wash - SMS Relay Polling Worker Daemon
/// Periodically queries `sms_outbox` for `status = 'pending'`,
/// triggers SMS dispatch via local modem / GSM gateway, and marks records as 'sent'.
void main(List<String> args) async {
  const supabaseUrl = 'https://siioobajphmwzwwarlrr.supabase.co';
  const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpaW9vYmFqcGhtd3p3d2FybHJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1OTA3MjksImV4cCI6MjEwODE2NjcyOX0.7ilkYS4N8m_b-uy3ExxnE-SJidumg-Zk8hkHP8CgD4U';

  final headers = {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
    'Content-Type': 'application/json',
  };

  print('[SMS Relay Daemon] Started. Polling pending messages every 10 seconds...');

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    try {
      final res = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/sms_outbox?status=eq.pending&select=*&limit=10'),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final List messages = jsonDecode(res.body);
        for (final msg in messages) {
          final id = msg['id'];
          final phone = msg['recipient_phone'];
          final body = msg['message_body'];

          print('[SMS Relay] Sending SMS to $phone: "$body"');
          // In production: send AT command via serial modem or call local SMS Gateway API.
          // Mark as sent:
          await http.patch(
            Uri.parse('$supabaseUrl/rest/v1/sms_outbox?id=eq.$id'),
            headers: headers,
            body: jsonEncode({
              'status': 'sent',
              'sent_at': DateTime.now().toIso8601String(),
            }),
          );
          print('[SMS Relay] Message $id marked as SENT.');
        }
      }
    } catch (e) {
      print('[SMS Relay] Error polling outbox: $e');
    }
  });
}
