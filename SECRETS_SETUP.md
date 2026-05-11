# GitHub Secrets Setup for Waypoint Release Pipeline

Go to: **GitHub → Repository → Settings → Secrets and variables → Actions → New repository secret**

Also create an environment named **`testflight`** under Settings → Environments — this gives you manual approval control before any release goes out.

---

## Required Secrets

### Code Signing

| Secret | How to get it |
|--------|--------------|
| `CERT_P12_BASE64` | Export your **iOS Distribution certificate** from Keychain Access as a `.p12` file, then run: `base64 -i YourCert.p12 \| pbcopy` |
| `CERT_PASSWORD` | The password you set when exporting the `.p12` |
| `KEYCHAIN_PASSWORD` | Any random strong string — used only for the CI temp keychain |
| `PROFILE_BASE64` | Download your **App Store Distribution provisioning profile** from developer.apple.com, then run: `base64 -i YourProfile.mobileprovision \| pbcopy` |

### App Store Connect

| Secret | How to get it |
|--------|--------------|
| `ASC_KEY_ID` | App Store Connect → Users and Access → Integrations → App Store Connect API → Key ID |
| `ASC_ISSUER_ID` | Same page — Issuer ID at the top |
| `ASC_KEY_BASE64` | Download the `.p8` key (only downloadable once!), then: `base64 -i AuthKey_XXXX.p8 \| pbcopy` |
| `APPLE_TEAM_ID` | developer.apple.com → Account → Membership — 10-character string |

---

## Release flow

```
git tag v1.0.0
git push origin v1.0.0
```

This triggers the release workflow:
1. Builds the app with your distribution certificate
2. Exports an IPA using App Store provisioning
3. Uploads to TestFlight automatically
4. Creates a GitHub Release with the IPA + dSYMs attached

The `testflight` environment can require manual approval before upload — configure reviewers in Settings → Environments.

---

## CI flow (no secrets needed)

Every push to `main` or `develop` automatically:
1. Generates the Xcode project from `project.yml`
2. Builds for the iOS Simulator (no signing)
3. Runs unit tests
4. Uploads test results as a build artifact
