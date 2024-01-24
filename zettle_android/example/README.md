# zettle_android_example

`zettle_ios_example` is a wrapper for the Zettle Android SDK so that it can be easily integrated into Flutter. In this flutter app example you can:
- Sign in and sign out of Zettle accounts
- Pair your phone with a Zettle card reader 
- Create payments
- Retrieve payments
- Request refunds

## Prerequisites

- Android version 5 (API level 21) or higher
- GitHub personal access token with scope `read:packages`, See [Generate a GitHub token](https://developer.zettle.com/docs/android-sdk/get-started#generate-a-github-token)
- Credentials for the app that include a client ID and a redirect URL (callback URL). If you don't have these, see [create credentials for an SDK app](https://developer.zettle.com/docs/get-started/user-guides/create-app-credentials/create-credentials-sdk-app).


## How to use this project?
### 1. Configure the example app
Fill in the `android/zettle.gradle` file with your personal access token.

```

// Personal access token with read rights to github package registry
ext.zettleSDK.githubAccessToken = ""

```

### 2. Setup Environment Variables
1. In the zettle_android/example create a copy of the .env.example file:
```bash
    cp .env.example .env
```

2. Replace with your credentials:
```ini
ZETTLE_CLIENT_ID="YOUR_ZETTLE_APP_CLIENT_ID"
ZETTLE_SCHEME="YOUR_ZETTLE_SCHEME"
ZETTLE_HOST="YOUR_ZETTLE_HOST"
```