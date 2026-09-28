Add-Type @"
using System; using System.Runtime.InteropServices;
public class W3 {
 [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
 [DllImport("user32.dll")] public static extern IntPtr FindWindow(string c, string w);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
 [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint f, int x, int y, uint d, UIntPtr e);
}
"@
$title = "TD_Perform"
do { Start-Sleep 1; $h = [W3]::FindWindow($null, $title) } until ($h -ne [IntPtr]::Zero)
Write-Host "Found window: $h"
Start-Sleep 3

[W3]::ShowWindow($h, 9) | Out-Null
[W3]::BringWindowToTop($h) | Out-Null
Write-Host "SetForegroundWindow: $([W3]::SetForegroundWindow($h))"

# Fallback: click the centre of the window, same as doing it by hand
$r = New-Object W3+RECT; [W3]::GetWindowRect($h, [ref]$r) | Out-Null
[W3]::SetCursorPos([int](($r.L+$r.R)/2), [int](($r.T+$r.B)/2)) | Out-Null
[W3]::mouse_event(0x2,0,0,0,[UIntPtr]::Zero); [W3]::mouse_event(0x4,0,0,0,[UIntPtr]::Zero)do { Start-Sleep 1
 $p = Get-Process TouchPlayer* -EA SilentlyContinue | ? { $_.MainWindowTitle -like "*perform*" }
} until ($p)
$h = $p[0].MainWindowHandle
