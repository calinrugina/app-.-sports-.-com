# sports-app
Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 10,000 days
for: CN=SPORTS.COM, OU=SPORTS.COM MEDIA GROUP LTD, O=SPORTS.COM, L=LONDON, ST=LONDON, C=UK
[Storing upload-keystore.jks]

## ANDROID
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
/// BUILD
flutter build appbundle --release

### FIXES
flutter gen-l10n
