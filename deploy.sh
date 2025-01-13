BUNDLE_PATH="build/app/outputs/bundle/release/app-release.aab"
APK_PATH="build/app/outputs/apks/release/app-release.apks"

rm ${APK_PATH}

flutter build appbundle

bundletool build-apks \
  --bundle=${BUNDLE_PATH} \
  --output=${APK_PATH} \
  
bundletool install-apks --apks=${APK_PATH}
