# Giám sát web từ bên ngoài

Cứ 10 phút, GitHub Actions gọi các web của TTM từ máy của GitHub (bên ngoài máy chủ web).
Web không vào được thì báo Telegram ngay, nhắc lại mỗi khoảng 30 phút, và báo khi web vào lại được.

- Danh sách địa chỉ và khoá Telegram nằm trong **Settings → Secrets and variables → Actions**:
  `DANH_SACH_URL` (các địa chỉ cách nhau dấu cách), `TG_BOT_TOKEN`, `TG_CHAT_ID`. Không ghi trong mã, không in ra nhật ký.
- Gửi tin thử: tab **Actions → Giám sát web → Run workflow**, đánh dấu "Gửi tin thử lên Telegram".
- Kho để công khai vì GitHub cho kho công khai chạy Actions miễn phí không giới hạn. Kho không chứa thông tin bí mật nào.
- GitHub tự tắt lịch của kho công khai không có hoạt động 60 ngày; bước cuối của quy trình tự ghi một dòng sau 45 ngày để giữ lịch.

Cài ngày 09/11/2026 (rà soát ttmnetwork.com, mục A5).

**09/11/2026 — danh sách tự cập nhật:** ngoài `DANH_SACH_URL`, mỗi lần chạy lấy thêm các web đang chạy từ Trung tâm điều hành
(secret `NGUON_DANH_SACH` = địa chỉ API, `GIAM_SAT_KHOA` = khoá truy cập). Web mới tạo trong Trung tâm tự được canh, không phải sửa secret.
Trung tâm không trả lời (máy chủ sập) → dùng danh sách lần trước, lưu **mã hoá** trong bộ nhớ đệm của Actions. Lịch chạy phút 4, 14, 24… mỗi giờ.
