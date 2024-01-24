# zettle_ios_example

`zettle_ios` is a wrapper for the Zettle iOS SDK so that it can be easily integrated into Flutter. In this flutter app example you can:
- Sign in and sign out of Zettle accounts
- Pair your phone with a zettle card reader 
- Create payments
- Retrieve payments
- Request refunds

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## How to use this project?
### 1. Setup Xcode credentials
Open the `GeneralSettings.xcconfig` file and replace your Apple Development Team and your Zettle App Scheme:

```ini
DEVELOPMENT_TEAM = YOUR_APPLE_DEVELOPMENT_TEAM
ZETTLE_SCHEME = YOUR_ZETTLE_APP_SCHEME
```

Currently the **"Automatically manage signing"** option is enabled for this project, but you can manually set these values directly in Xcode if you prefer. The Apple Development Team can be found under "Signing and Capabilities" tab in the "Runner" target and the Zettle App Scheme can be found in the `info.plist` file under the "URL Schemes" key.

### 2. Setup Environment Variables
1. In the zettle_ios/example create a copy of the .env.example file:
```bash
    cp .env.example .env
```

2. Replace with your credentials:
```ini
ZETTLE_CLIENT_ID="YOUR_ZETTLE_APP_CLIENT_ID"
ZETTLE_REDIRECT_URL="YOUR_ZETTLE_REDIRECT_URL"  
```

