#!/usr/bin/env bash
# Kiểm các web từ BÊN NGOÀI máy chủ (chạy trên máy của GitHub Actions), báo Telegram khi không vào được và khi vào lại được.
# Danh sách địa chỉ và khoá Telegram nằm trong Secrets của kho (DANH_SACH_URL, TG_BOT_TOKEN, TG_CHAT_ID), không ghi ra nhật ký công khai.
# Trạng thái lần trước giữ trong trang-thai.txt (bộ nhớ đệm của Actions) để chỉ báo khi đổi trạng thái, nhắc lại mỗi ~30 phút khi còn hỏng.
set -u
gui() {
  [ -n "${TG_BOT_TOKEN:-}" ] && [ -n "${TG_CHAT_ID:-}" ] || return 0
  curl -sS --max-time 20 "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TG_CHAT_ID}" --data-urlencode "text=$1" >/dev/null || true
}
GIO=$(TZ=Asia/Ho_Chi_Minh date '+%H:%M %d/%m/%Y')
read -r TT_CU DEM_CU < <(cat trang-thai.txt 2>/dev/null || echo "ok 0")
HONG=""; SO_TOT=0; TONG=0
for u in ${DANH_SACH_URL:-}; do
  TONG=$((TONG + 1)); ma=000
  for lan in 1 2 3; do
    ma=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 -A "Mozilla/5.0 (giam-sat-ttm)" "$u" || true)
    case "$ma" in 2??|3??) break ;; esac
    [ "$lan" -lt 3 ] && sleep 15
  done
  case "$ma" in 2??|3??) SO_TOT=$((SO_TOT + 1)) ;; *) HONG="$HONG"$'\n'"❌ ${u#https://} → mã ${ma:-000}" ;; esac
done
[ "$TONG" -gt 0 ] || { echo "Chưa đặt DANH_SACH_URL trong Secrets"; exit 1; }

if [ -n "$HONG" ]; then
  DEM=$(( ${DEM_CU:-0} + 1 ))
  if [ "$TT_CU" != hong ] || [ $(( DEM % 3 )) -eq 0 ]; then
    gui "🚨 WEB KHÔNG VÀO ĐƯỢC — $GIO ($SO_TOT/$TONG web còn chạy)$HONG
Kiểm từ máy chủ GitHub, bên ngoài máy chủ OVH: có thể máy chủ sập, mất mạng hoặc Cloudflare lỗi."
  fi
  echo "hong $DEM" > trang-thai.txt
else
  [ "$TT_CU" = hong ] && gui "✅ Các web đã vào lại được — $GIO ($SO_TOT/$TONG web chạy)"
  echo "ok 0" > trang-thai.txt
fi
[ "${THU:-false}" = true ] && gui "🔧 THỬ giám sát từ bên ngoài — $GIO: $SO_TOT/$TONG web đang chạy. Web nào không vào được sẽ báo như thế này, 10 phút kiểm một lần."
# Thứ Hai khoảng 8 giờ sáng báo một dòng để biết bộ giám sát vẫn sống
if [ "$(TZ=Asia/Ho_Chi_Minh date +%u%H)" = "108" ] && [ "$(TZ=Asia/Ho_Chi_Minh date +%-M)" -lt 10 ]; then gui "ℹ️ Giám sát ngoài vẫn chạy — $SO_TOT/$TONG web tốt lúc $GIO"; fi
echo "Kết quả $GIO: $SO_TOT/$TONG web tốt"   # không in địa chỉ: nhật ký của kho công khai ai cũng xem được
[ -z "$HONG" ]
