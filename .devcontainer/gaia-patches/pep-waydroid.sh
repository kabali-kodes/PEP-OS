#!/system/bin/sh
# PEP OS Waydroid Runtime
waydroid init -f || true
waydroid session start &
waydroid container start &
echo "PEP Waydroid running"

while true; do
  echo "PEP Bridge: waiting for APK on 2222"
  echo -e "HTTP/1.1 200 OK\r\n\r\nOK" | nc -l -p 2222 -q 1 > /tmp/req
  APK=$(cat /tmp/req | grep -o '/sdcard/[^"]*.apk' | head -1)
  [ -n "$APK" ] && waydroid app install $APK
done