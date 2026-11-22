"""
BISHE Super AI Sentinel — Windows Desktop Toast & Sound Notifier
Pops up native desktop notifications on your laptop when high-risk anomalies occur.
"""

import subprocess
import os

class DesktopNotifier:
    @staticmethod
    def show_alert(title: str, message: str, is_critical: bool = False):
        try:
            # Escape strings for PowerShell
            clean_title = title.replace('"', '`"').replace("'", "`'")
            clean_msg = message.replace('"', '`"').replace("'", "`'").replace("\n", " ")
            icon_type = "Error" if is_critical else "Warning"

            ps_script = f"""
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
            $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
            $objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
            $objNotifyIcon.BalloonTipIcon = "{icon_type}"
            $objNotifyIcon.BalloonTipTitle = "{clean_title}"
            $objNotifyIcon.BalloonTipText = "{clean_msg}"
            $objNotifyIcon.Visible = $True
            $objNotifyIcon.ShowBalloonTip(5000)
            """
            subprocess.Popen(
                ["powershell", "-NoProfile", "-WindowStyle", "Hidden", "-Command", ps_script],
                creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0)
            )
        except Exception as e:
            print(f"[DesktopNotifier] Notice: {e}")
