#!/bin/bash
set -e

echo "=== 1. Setting up build directories ==="
rm -rf /tmp/apk_build
mkdir -p /tmp/apk_build/src/com/example/islami
mkdir -p /tmp/apk_build/gen
mkdir -p /tmp/apk_build/res/drawable
mkdir -p /tmp/apk_build/classes
mkdir -p /tmp/apk_build/assets

echo "=== 2. Preparing Icon and Manifest ==="
cp /app/applet/assets/images/quran.png /tmp/apk_build/res/drawable/icon.png

cat << 'EOF' > /tmp/apk_build/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.islami"
    android:versionCode="1"
    android:versionName="1.0.0">

    <uses-sdk android:minSdkVersion="21" android:targetSdkVersion="33" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:label="إسلامي"
        android:icon="@drawable/icon"
        android:allowBackup="true"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.NoTitleBar">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="orientation|screenSize|keyboardHidden">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

echo "=== 3. Writing MainActivity.java ==="
cat << 'EOF' > /tmp/apk_build/src/com/example/islami/MainActivity.java
package com.example.islami;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.view.KeyEvent;

public class MainActivity extends Activity {
    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        webView = new WebView(this);
        setContentView(webView);

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        settings.setAllowFileAccessFromFileURLs(true);
        settings.setAllowUniversalAccessFromFileURLs(true);
        settings.setDatabaseEnabled(true);
        settings.setMediaPlaybackRequiresUserGesture(false);

        webView.setWebViewClient(new WebViewClient());
        webView.setWebChromeClient(new WebChromeClient());

        webView.loadUrl("file:///android_asset/dist/index.html");
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && webView.canGoBack()) {
            webView.goBack();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }
}
EOF

echo "=== 4. Generating R.java with aapt ==="
aapt package -f -m -J /tmp/apk_build/gen \
    -M /tmp/apk_build/AndroidManifest.xml \
    -S /tmp/apk_build/res \
    -I /usr/share/android-framework-res/framework-res.apk

echo "=== 5. Compiling Java Classes with javac ==="
javac -source 1.8 -target 1.8 \
    -cp /tmp/android.jar \
    -d /tmp/apk_build/classes \
    /tmp/apk_build/src/com/example/islami/MainActivity.java \
    /tmp/apk_build/gen/com/example/islami/R.java

echo "=== 6. Creating classes.dex with dalvik-exchange ==="
/usr/bin/dalvik-exchange --dex --output=/tmp/apk_build/classes.dex /tmp/apk_build/classes

echo "=== 7. Packaging Web Assets into Android Assets ==="
mkdir -p /tmp/apk_build/assets/dist
cp -r /app/applet/dist/* /tmp/apk_build/assets/dist/
mkdir -p /tmp/apk_build/assets/assets
cp -r /app/applet/assets/* /tmp/apk_build/assets/assets/

echo "=== 8. Packaging APK with aapt ==="
aapt package -f \
    -M /tmp/apk_build/AndroidManifest.xml \
    -S /tmp/apk_build/res \
    -A /tmp/apk_build/assets \
    -I /usr/share/android-framework-res/framework-res.apk \
    -F /tmp/apk_build/unaligned.apk

cd /tmp/apk_build
aapt add unaligned.apk classes.dex

echo "=== 9. Zipalign APK ==="
zipalign -v -p 4 /tmp/apk_build/unaligned.apk /tmp/apk_build/aligned.apk

echo "=== 10. Signing APK with apksigner ==="
if [ ! -f /tmp/release.keystore ]; then
    keytool -genkey -v -keystore /tmp/release.keystore \
        -alias islami -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass islami123 -keypass islami123 \
        -dname "CN=Islami, OU=App, O=Islami, L=Cairo, S=Cairo, C=EG"
fi

apksigner sign --ks /tmp/release.keystore --ks-pass pass:islami123 \
    --out /app/applet/islami.apk /tmp/apk_build/aligned.apk

echo "=== 11. Verifying APK ==="
apksigner verify /app/applet/islami.apk

echo "=== SUCCESS! APK generated at /app/applet/islami.apk ==="
ls -lh /app/applet/islami.apk
