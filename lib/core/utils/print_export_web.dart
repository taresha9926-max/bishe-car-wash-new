// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

void downloadFile(String filename, String content, String mimeType) {
  try {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  } catch (_) {}
}

void printDocument(String title, String htmlBody) {
  try {
    final styledHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>$title</title>
  <style>
    @page { margin: 12mm; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans Ethiopic", Helvetica, Arial, sans-serif;
      color: #111827;
      background: #ffffff;
      margin: 0;
      padding: 12px;
      line-height: 1.4;
    }
    .header {
      text-align: center;
      border-bottom: 2px dashed #0284C7;
      padding-bottom: 10px;
      margin-bottom: 12px;
    }
    .station-name {
      font-size: 18px;
      font-weight: 900;
      letter-spacing: 0.5px;
      color: #0284C7;
    }
    .station-sub {
      font-size: 11px;
      color: #4B5563;
      margin-top: 2px;
    }
    .doc-title {
      font-size: 14px;
      font-weight: 800;
      color: #111827;
      margin-top: 6px;
      text-transform: uppercase;
      letter-spacing: 0.3px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 10px;
      font-size: 11px;
    }
    th {
      background: #0284C7;
      color: white;
      font-weight: 700;
      text-align: left;
      padding: 6px 8px;
      border: 1px solid #0284C7;
    }
    td {
      padding: 5px 8px;
      border-bottom: 1px solid #E5E7EB;
    }
    .total-row {
      font-weight: 800;
      font-size: 12px;
      background: #F9FAFB;
      border-top: 2px solid #374151;
    }
    .footer {
      margin-top: 18px;
      text-align: center;
      font-size: 10px;
      color: #6B7280;
      border-top: 1px dashed #D1D5DB;
      padding-top: 8px;
    }
    @media print {
      body { padding: 0; }
    }
  </style>
</head>
<body>
  $htmlBody
</body>
</html>
''';

    final iframe = html.IFrameElement()
      ..style.position = 'fixed'
      ..style.top = '-10000px'
      ..style.left = '-10000px'
      ..style.width = '10px'
      ..style.height = '10px'
      ..style.border = 'none'
      ..srcdoc = styledHtml;

    html.document.body?.children.add(iframe);

    iframe.onLoad.first.then((_) {
      try {
        final contentWin = js_util.getProperty(iframe, 'contentWindow');
        if (contentWin != null) {
          js_util.callMethod(contentWin, 'focus', const []);
          js_util.callMethod(contentWin, 'print', const []);
        } else {
          html.window.print();
        }
      } catch (_) {
        html.window.print();
      }
      Future.delayed(const Duration(seconds: 2), () {
        iframe.remove();
      });
    });
  } catch (_) {
    try {
      html.window.print();
    } catch (_) {}
  }
}
