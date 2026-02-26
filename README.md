# OCR Camera App (Flutter)

This project is a Flutter mobile app that uses:

- `camera` for live rear-camera preview and manual photo capture
- `google_mlkit_text_recognition` for on-device OCR
- `permission_handler` for runtime camera permissions

The app flow is:

1. Launch app → live rear camera preview
2. Tap **Capture** → take a photo (no realtime OCR on preview)
3. OCR runs on captured image
4. App shows captured image and detected text in a scrollable area
5. Tap **Retake** to return to camera preview

---

## 1) Environment setup

### 1.1 Install Flutter SDK

1. Download Flutter from the official docs:
   - https://docs.flutter.dev/get-started/install
2. Extract and add Flutter to your `PATH`.
3. Verify installation:

```bash
flutter --version
flutter doctor
```

Resolve all issues reported by `flutter doctor` before proceeding.

### 1.2 Install Android toolchain

1. Install **Android Studio**.
2. Open Android Studio → **SDK Manager** and install:
   - Android SDK Platform (latest stable)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android Emulator (optional if using physical device)
3. Accept Android licenses:

```bash
flutter doctor --android-licenses
```

### 1.3 (Optional) Install iOS toolchain (macOS only)

1. Install Xcode from App Store.
2. Open Xcode once and accept license.
3. Install CocoaPods:

```bash
sudo gem install cocoapods
```

4. Verify:

```bash
flutter doctor
```

---

## 2) Get the project and dependencies

From your terminal:

```bash
git clone <your-repo-url>
cd OCR_packages
flutter pub get
```

Confirm connected devices:

```bash
flutter devices
```

---

## 3) Configure permissions (already included in this repo)

This repository already includes camera permissions:

- Android: `android/app/src/main/AndroidManifest.xml`
  - `android.permission.CAMERA`
- iOS: `ios/Runner/Info.plist`
  - `NSCameraUsageDescription`

If you rename package IDs or regenerate platform folders, ensure these entries remain.

---

## 4) Run the app in debug mode

### Android phone (recommended first run)

1. On your phone, enable:
   - **Developer options**
   - **USB debugging**
2. Connect phone via USB.
3. Verify device connection:

```bash
adb devices
```

4. Run app:

```bash
flutter run
```

When prompted on device, allow camera permission.

---

## 5) Build release APK

From project root:

```bash
flutter build apk --release
```

Generated APK path:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 6) Install APK on Android phone

### Option A: Install via ADB (USB)

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

- `-r` reinstalls while keeping app data where possible.

### Option B: Install manually

1. Copy `app-release.apk` to your phone.
2. Open the APK file on phone.
3. Allow **Install unknown apps** for your file manager/browser when asked.
4. Complete installation.

---

## 7) Verify expected app behavior

After installation:

1. App opens to live rear camera preview.
2. Tap **Capture** to take a photo.
3. OCR loading indicator appears.
4. Captured image is shown.
5. Recognized text appears in scrollable area below.
6. Tap **Retake** to capture another image.

---

## 8) Troubleshooting

### Flutter command not found

- Ensure Flutter `bin` directory is on your `PATH`.
- Restart terminal and re-run `flutter --version`.

### No device detected

- Reconnect USB cable.
- Confirm USB debugging is enabled.
- Run `adb devices` and accept RSA prompt on phone.

### Camera unavailable / permission denied

- Check app camera permission in phone Settings.
- Reinstall app if permission state is inconsistent.

### Build fails with Android SDK errors

- Open Android Studio and install missing SDK packages.
- Run `flutter doctor` to identify missing components.

### Build failed due to deleted Android v1 embedding

This project uses Android v2 embedding. If you still see this error, check these points:

- `MainActivity` must extend `io.flutter.embedding.android.FlutterActivity` (not `io.flutter.app.FlutterActivity`).
- Ensure your Android entrypoint exists at:
  - `android/app/src/main/kotlin/com/example/ocr_packages/MainActivity.kt`
- If your local `android/` folder was generated earlier with old templates, regenerate platform files safely:

```bash
flutter create .
flutter pub get
```

Then reapply custom manifest permission entries if needed and run:

```bash
flutter clean
flutter run
```

---

## 9) Optional: Build and install App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Use this for Play Store uploads (not direct phone sideloading).
