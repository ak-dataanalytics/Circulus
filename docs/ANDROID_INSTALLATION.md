# CIRCULUS Android Installation & Physical Device Testing Guide

This guide details how to build the CIRCULUS Android APK, connect it to your development machine, and install it on an Android phone.

---

## 1. Prerequisites on Windows
1. **Flutter SDK**: Installed and added to PATH (`flutter --version`).
2. **Android Studio**: Installed with Android SDK Platform 34 and Command-line Tools.
3. **USB Debugging**: Enabled on your physical Android smartphone:
   - Go to **Settings > About Phone** -> Tap **Build Number** 7 times.
   - Go to **Settings > Developer Options** -> Enable **USB Debugging**.

---

## 2. Network Configuration for Physical Device Testing

Your smartphone and development PC must be on the **same Wi-Fi network**.

### Step 2.1: Find Your Laptop's Local IP
Open PowerShell on your Windows machine:
```powershell
ipconfig
```
Look for `IPv4 Address` under your active Wi-Fi adapter, for example: `192.168.1.15`.

### Step 2.2: Update Mobile API Endpoint
Open `mobile/lib/core/constants/api_constants.dart` and update the base URL:
```dart
static String get baseUrl {
  // Replace with your laptop's Wi-Fi IP address:
  return 'http://192.168.1.15:8000/api/v1';
}
```

### Step 2.3: Start Backend Binding to All Interfaces
Ensure the FastAPI backend is running on `0.0.0.0`:
```powershell
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 3. Building the Android Debug APK

Run the following commands from the `mobile` directory:

```powershell
cd mobile
flutter clean
flutter pub get
flutter build apk --debug
```

### Build Artifact Output
Upon successful compilation, the installable APK is located at:
```
mobile/build/app/outputs/flutter-apk/app-debug.apk
```

---

## 4. Installing the APK on Your Android Device

### Option A: Direct ADB Installation over USB (Recommended)
Connect your Android phone to your PC via USB cable.
1. Check connected device:
   ```powershell
   adb devices
   ```
   (Verify your phone appears as `device`).
2. Install the APK directly:
   ```powershell
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   ```

### Option B: Direct Phone Download / Transfer
1. Copy `app-debug.apk` to your phone via USB file transfer, Google Drive, or local file sharing.
2. Open the file on your Android phone using your **Files** app.
3. Tap **Install** (Allow "Install Unknown Apps" if prompted).
4. Launch **CIRCULUS**.

---

## 5. Verification Checklist on Android Phone
- [ ] CIRCULUS launches with the Navy & Gold splash screen.
- [ ] Welcome screen presents the invitation-only gate.
- [ ] Tap **HAVE AN INVITATION? REGISTER**.
- [ ] Enter `CIRCULUS2026` to validate.
- [ ] Complete registration.
- [ ] Play a round of **Sudoku** or **GK Quiz** in the **Brain Arena**.
- [ ] Check your updated points on the **Weekly Podium**!
