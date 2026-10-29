### Download

| Platform | File |
| --- | --- |
| Windows 10 and 11 (most PCs) | `Adawat-Setup-x64.exe` |
| Windows on ARM | `Adawat-Setup-arm64.exe` |
| Mac with Apple silicon (M1 and later) | `Adawat-arm64.dmg` |
| Mac with Intel | `Adawat-x86_64.dmg` |
| Ubuntu, Debian, Mint, Pop!_OS | `Adawat-linux-amd64.deb` (ARM: `Adawat-linux-arm64.deb`) |
| Fedora, openSUSE | `Adawat-linux-x86_64.rpm` (ARM: `Adawat-linux-aarch64.rpm`) |
| Any Linux | `Adawat-x86_64.AppImage` (ARM: `Adawat-aarch64.AppImage`) |
| Android 10 and later | `Adawat-Android.apk` |

### Installing
- **Windows:** the installer is not code-signed, so SmartScreen may say "Windows protected your PC". Choose **More info**, then **Run anyway**.
- **Mac:** the app is not notarized by Apple. Open the disk image, drag Adawat to Applications, then right-click Adawat and choose **Open** the first time. If macOS says the app is damaged, run `xattr -dr com.apple.quarantine /Applications/Adawat.app` in Terminal.
- **Linux:** install the .deb with `sudo apt install ./Adawat-linux-amd64.deb`, or the .rpm with `sudo dnf install ./Adawat-linux-x86_64.rpm`. For the AppImage, run `chmod +x Adawat-*.AppImage` and open it.
- **Android:** allow installing apps from your browser or file manager when asked. This build is signed with a different key from the original Adawat, so uninstall the original first.
