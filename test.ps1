Add-Type @"
using System; using System.Runtime.InteropServices;
public class Win {
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr FindWindow(string c, string w);
 [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, UIntPtr e);
}
"@
do { Start-Sleep 1; $h = [Win]::FindWindow($null, "TD_Perform") } until ($h -ne [IntPtr]::Zero)
Start-Sleep 2
[Win]::keybd_event(0x12,0,0,[UIntPtr]::Zero); [Win]::keybd_event(0x12,0,2,[UIntPtr]::Zero)
[Win]::SetForegroundWindow($h)
