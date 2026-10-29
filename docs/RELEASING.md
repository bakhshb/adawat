# Releasing Adawat

Every release is built on GitHub, so no Windows or Mac machine is needed. The workflow is `.github/workflows/release.yml`.

## Make a release

1. Set the new version in three places: `windows/Directory.Build.props`, `linux/Directory.Build.props` and `versionName` in `android/app/build.gradle.kts`. The Mac build reads the Windows file. The workflow stops if the three differ.
2. Commit and push to `main`.
3. On GitHub, open **Actions → Release → Run workflow** and pick `main`.
4. When it finishes, open **Releases**. There is a draft named `Adawat <version>` with every file, the install notes and the SHA-256 checksums.
5. Check the draft, edit the notes if you like, then press **Publish release**. Nothing is published before that.

Running the workflow again for the same version replaces the files in the waiting draft. Once a version is published, raise the version to release again.

If one platform fails to build, the others are still uploaded, and the draft names the missing platform at the top. Fix it and run the workflow again before you publish.

## What runs

| Job | Runner | Makes |
| --- | --- | --- |
| Tests and version | ubuntu-latest | Runs `dotnet test` on `windows/tests/Adawat.Core.Tests` and checks the versions match. Nothing builds if this fails. |
| Windows installers | windows-latest | `Adawat-Setup-x64.exe`, `Adawat-Setup-arm64.exe` (Inno Setup, as `windows/tools/build-installer.sh` does) |
| Mac | macos-26 (Apple silicon) and macos-15-intel | `Adawat-arm64.dmg`, `Adawat-x86_64.dmg` (`scripts/build-ffmpeg.sh`, then `scripts/build-app.sh --dmg`) |
| Linux packages | ubuntu-latest | .deb, .rpm and AppImage for x64 and ARM64 (`linux/tools/build-packages.sh`) |
| Android APK | ubuntu-latest | `Adawat-Android.apk` (`./gradlew assembleRelease`) |
| Draft release | ubuntu-latest | The draft release, with all the files and `SHA256SUMS` |

The Mac ffmpeg is built from source the first time, which takes a while. It is cached for later runs until `scripts/build-ffmpeg.sh` changes.

## Updates

Builds from this workflow check **this repository's** releases for updates, not the original `motalim-ai/adawat`. The workflow passes the repository name to the build (`UpdateRepository` for Windows and Linux, `adawat.updateRepository` for Android). Builds made without it check `motalim-ai/adawat`, as before.

The in-app updater only offers a **published** release that is newer than the installed version. It needs these exact file names, which the workflow uses: `Adawat-Setup-x64.exe`, `Adawat-Setup-arm64.exe`, the AppImage, .deb and .rpm names above, and `Adawat-Android.apk`. It checks each download against the SHA-256 that GitHub records for the file. The Mac app has no in-app updater.

## Signing

| Platform | Signed? | What users see |
| --- | --- | --- |
| Windows | No code-signing certificate | SmartScreen may warn: **More info → Run anyway**. |
| Mac | Ad-hoc signature only, not notarized | Gatekeeper blocks the first open: right-click → **Open**, or `xattr -dr com.apple.quarantine /Applications/Adawat.app`. |
| Linux | Packages are not GPG-signed | Nothing; installs normally. |
| Android | Signed when the secrets below are set | See below. |

### Android signing key

Android only installs a signed APK, and only installs an update signed with the **same** key. Make one key and keep it forever: if you lose it, people must uninstall the app to get updates.

1. Make the key once, on any computer with Java:
   ```
   keytool -genkeypair -v -keystore adawat-upload.jks -alias adawat -keyalg RSA -keysize 4096 -validity 10000
   ```
2. Save a copy of `adawat-upload.jks` and its passwords somewhere safe, outside the repository.
3. In the repository, open **Settings → Secrets and variables → Actions → New repository secret** and add:

   | Secret | Value |
   | --- | --- |
   | `ANDROID_KEYSTORE_BASE64` | the output of `base64 -w0 adawat-upload.jks` (on a Mac: `base64 -i adawat-upload.jks`) |
   | `ANDROID_KEYSTORE_PASSWORD` | the keystore password |
   | `ANDROID_KEY_ALIAS` | `adawat` (the alias above) |
   | `ANDROID_KEY_PASSWORD` | the key password |

Without these secrets the workflow still builds, but uploads `Adawat-Android-unsigned.apk`, which Android refuses to install. The in-app updater ignores it because of its name.

Your key differs from the original developer's, so your APK cannot install over the original Adawat from `motalim-ai/adawat`. Users must uninstall that one first. Updates between your own releases work.

### Windows and Mac signing (optional, not set up)

- **Windows:** with a code-signing certificate, add a `signtool sign` step after the installers are built in the Windows job.
- **Mac:** with an Apple Developer ID, replace the ad-hoc `codesign --sign -` in `scripts/build-app.sh` with your identity, then notarize the .dmg with `xcrun notarytool submit --wait` and `xcrun stapler staple`. The certificate and an app-specific password would go into secrets.
