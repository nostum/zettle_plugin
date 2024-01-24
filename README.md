# Zettle SDK for flutter by Nostum

Zettle plugin, developed by [Nostum Technologies](https://www.nostum.com), provides the facility to integrate the paypal Zettle terminal in flutter applications to be able to make payments for both Android and iOS platforms. This is a non-official plugin and it's not intended to be used for production yet.

## Prerequisites

1) Register for a Zettle developer account via [Zettle](https://developer.zettle.com/docs/get-started/user-guides/sign-up-for-a-developer-account).
2) Create an app on Zettle from the developer portal.
3) Generate a GitHub token (The Zettle Payments SDK for Android is available as packages from the GitHub Package Registry)
4) Ensure your iOS deployment target is set to version 12.0 or higher.
5) Set the minSdkVersion for your Android app to 21 or higher.
6) Ensure your Xcode version is 14.1 or higher.



## Android installation

### 1. Update `build.gradle`

Add the following code to your build.gradle file to install the SDK:

```
android {
    packagingOptions {
        exclude 'META-INF/*.kotlin_module'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://maven.pkg.github.com/iZettle/sdk-android")
            credentials(HttpHeaderCredentials) {
                name "Authorization"
                value "Bearer <YOUR TOKEN>"
            }
            authentication {
                header(HttpHeaderAuthentication)
            }
        }
    }
}
```
Be sure to replace [YOUR TOKEN] with the github token you previously created.

### 2. Update AndroidManifest.xml

Include the following code in your `AndroidManifest.xml` file as specified by the [Zettle Android SDK](https://github.com/iZettle/sdk-android):

```
<activity
    android:name="com.izettle.android.auth.OAuthActivity"
    android:launchMode="singleTask"
    android:taskAffinity="@string/oauth_activity_task_affinity"
    android:exported="true">
    <intent-filter>
        <data
            android:host="[YOUR REDIRECT HOST]"
            android:scheme="[YOUR REDIRECT SCHEME]" />
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
    </intent-filter>
</activity>
```

Make sure to replace [YOUR REDIRECT HOST] and [YOUR REDIRECT SCHEME] with the appropriate values for your application. These values should match the redirect URI configured in your Zettle developer account.


## iOS installation

### 1. Set up external accessory communication background mode

#### 1.1 Xcode modifications
**In Xcode 14.1**:

Select the following background modes to enable support for external accessory communication. You can find them under Signing & Capabilities in your target.
- External accessory communication
- Uses Bluetooth LE accessory

**In earlier Xcode versions**

In your Xcode project, select the Capabilities tab. Go to the **Background modes** section to enable external accessory communication support.

#### 1.2 Info.plist modifications
Edit your Info.plist file to have the following information set:

``` xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Our app uses bluetooth to find, connect and transfer data with Zettle card reader devices.</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>Our app uses bluetooth to find, connect and transfer data with Zettle card reader devices.</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>"The scheme of your OAuth Redirect URI *"</string>          // Example: if your oAuth Redirect URI is "awesomeapp://zettlelogin", then the scheme of your OAuth Redirect URI is "awesomeapp"
        </array>
    </dict>
</array>
```

#### 1.3 Set up external accessory protocols
In your `Info.plist`, add/modify the property Supported external accessory protocols and add `com.izettle.cardreader-one` as shown below:

``` xml
<key>UISupportedExternalAccessoryProtocols</key>
 <array>
     <string>com.izettle.cardreader-one</string>
 </array>
```

### 2. Set up CLLocationManager
Add the key in your Info.plist:
```xml 
<key>NSLocationWhenInUseUsageDescription</key>
<string>You need to allow this to be able to accept card payments</string>

```

> This documentation has been extracted from [The Zettle iOS SDK official documentation](https://developer.zettle.com/docs/ios-sdk/installation-and-configuration) please refer to the original documentation for more details.

## Getting Started

Import the package:

```dart
import 'package:zettle/zettle.dart';

```

Initialize `ZettlePlugin` before using it:

```dart
import 'package:zettle/zettle.dart';

void main() async {

    await ZettlePlugin().initialize(
        iosClientId: ZETTLE_IOS_CLIENT_ID,
        androidClientId: ZETTLE_ANDROID_CLIENT_ID,
        redirectUrl: ZETTLE_REDIRECT_URL,
    );

  runApp(MyApp());
}
```
Ensure you replace placeholders with your actual Zettle client IDs and redirect URL.

## Usage example

### Login

Authenticate the user with Zettle by calling the login method.

```dart
final _zettlePlugin = ZettlePlugin();

await _zettlePlugin.login();
```

### Logout

Logout the user from Zettle using the logout method.

```dart
final _zettlePlugin = ZettlePlugin();

await _zettlePlugin.logout();
```

### Show Settings

Open the Zettle settings page using the showSettings method.

```dart
final _zettlePlugin = ZettlePlugin();

await _zettlePlugin.showSettings();
```

### Create payment
Send a payment request to the Zettle card reader for a specific amount
```dart
    final _zettlePlugin = ZettlePlugin();
    final request = ZettlePaymentRequest(amount: amount, reference: reference);
    await _zettlePlugin.requestPayment(request);
```
:warning: Note: You should save the payment reference so that you can retrieve and refund it later

### Retrieve payment
Retrieve payment information using a reference.
```dart
    final _zettlePlugin = ZettlePlugin();
    await _zettlePlugin.retrievePayment(reference);
```

### Refund payment
Refund a payment using a reference and specifying the amount.
```dart
    final _zettlePlugin = ZettlePlugin();
   final request = ZettleRefundRequest(reference: reference, refundAmount: amount);
    await _zettlePlugin.requestRefund(request);
```