# Nghiên cứu tích hợp thanh toán — Tree Store

*Cập nhật: 2026-09-14. Range: khách hàng VN, app Android (Flutter) + backend Ktor.*

---

## 1. Hiện trạng hệ thống

### Đã có

| Thành phần | Vị trí | Ghi chú |
|---|---|---|
| Enum `PaymentMethod` (cod / bank_transfer / e_wallet) | `tree_store_app/lib/domain/entities/order.dart:24` | Đã map API string |
| Enum `PaymentStatus` (unpaid / paid / refunded) | `tree_store_app/lib/domain/entities/order.dart:50` | Thiếu trạng thái trung gian |
| Cột `payment_method`, `payment_status` | `kotlin_backend/.../Tables.kt:101-102` | orders table, default `cod`/`unpaid` |
| Tạo order | `kotlin_backend/.../Routes.kt:441` (`POST /api/orders`) | Hardcode `paymentStatus = "unpaid"`, **không có endpoint xác nhận thanh toán** |
| Màn checkout | `tree_store_app/.../checkout/checkout_screen.dart:29` | Chọn `cod`/`bank`, **delay giả 2s** (dòng 109), không gọi gateway nào |

### Chưa có

- Bảng `payments` (giao dịch riêng, tách khỏi orders)
- Endpoint tạo thanh toán + webhook/IPN
- Verify chữ ký gateway
- Package `crypto` (cần cho HMAC-SHA256/SHA512 — chưa có trong `pubspec.yaml`)
- WebView / deep link để thoát app trả kết quả

**Kết luận:** mọi thứ đang là mock. Order tạo ra mãi mãi `unpaid` trừ khi admin sửa DB.

---

## 2. Landscape cổng thanh toán Việt Nam

### 2.1 So sánh

| Cổng | Ký chữ ký | Luồng mobile | Webhook | Sandbox | Chi phí tham khảo* | Phù hợp app này |
|---|---|---|---|---|---|---|
| **VNPAY** | SHA512 (`SecureHash`) | `payform` GET → browser/WebView → `redirect` + `IPN` | IPN server-to-server, phải trả `{"code":"00"}` | có (`sandbox.vnpayment.vn`) | ~0,9–1,1%/QR; CK thường tính theo gói | ⭐⭐⭐ Phổ biến nhất, nhiều NH hỗ trợ QR |
| **MoMo** | HMAC-SHA256 | `partnerCode,price,orderInfo,returnTo,ipnUrl` → `payUrl` (WebView) hoặc app-to-app (`momo://`) | IPN JSON, phải trả `{"status":0}` | có (`test-payment-api.momo.vn`) | ~1,2–1,5% ví | ⭐⭐⭐ UX đẹp, docs tốt |
| **ZaloPay** | HMAC-SHA256 (`client_id + master_key_secret`) | app-to-app qua `zp://` hoặc browser `trans-info` | `sgn` verify bằng user id key | sandbox `sandbox-alipay.zalopay.vn` | ~1,5–1,8% | ⭐⭐ Lượng người dùng Zalo khổng lồ |
| **PayOS** | HMAC-SHA256 | `POST /api/v1/paymentLinks` → trả `checkoutUrl` + `qrCode` (WebView/browser) | **Webhook chủ động retry**; có `bin` + `amount` xác nhận CK tự động | `api-merchant.payos.vn` (test) | ~1,1%/QR; CK 0đ khi dùng `bin` | ⭐⭐⭐⭐ **Dễ tích hợp nhất**, không cần hợp đồng từng NH |
| **2PAY / 9Pay (CK tự động)** | API + socket | generate số TK virtual `2PAY_<orderid>` | QR/websocket báo "giao dịch về" | có | gói theo tháng | ⭐⭐ Tự xác nhận chuyển khoản — hay cho cây cảnh giá cao |
| **Viettel Money / TrueMoney / ShopeePay** | HMAC các kiểu | tương tự MoMo | có | hạn chế | ~1,5%+ | ⭐ Sau này |

\* phí thay đổi theo hợp đồng; số chỉ để so sánh tương đối.

### 2.2 Cơ chế chung (rất giống nhau)

```
Client/App                 Backend (mình)                Gateway
   │  checkout order  ────────►│                                │
   │                           │ create payment, sign ─────────►│
   │  ◄──── payUrl / QR ───────│                                │
   │  mở WebView/browser ─────────────────────────────────────► │  user trả tiền
   │                           │ ◄─── IPN/webhook (sign) ───────│
   │                           │ verify sign + so sánh amount   │
   │                           │ orders.paymentStatus = paid    │
   │  poll GET /api/orders/:id ─►│  (webhook là nguồn sự thật — │
   │  ◄──── paid ──────────────│   KHÔNG tin client)            │
```

Ba bài học kinh nghiệm quan trọng nhất:

1. **Webhook là nguồn chân lý duy nhất.** Kết quả `redirect` về app chỉ để hiển thị, không dùng để đổi trạng thái — user có thể chặn/tạo giả.
2. **Verify chữ ký + so số tiền server-side.** Amount luôn tính lại từ DB (subtotal + ship − discount), không nhận từ client.
3. **Idempotent webhook.** Gateway gửi lại nhiều lần; xử lý `INSERT ... ON CONFLICT DO NOTHING` theo `provider_txn_id`, không cộng tiền 2 lần.

---

## 3. Kiến trúc đề xuất

### 3.1 Backend — abstraction 1 provider interface

```kotlin
interface PaymentProvider {
    val code: String                       // "vnpay" | "momo" | "zalopay" | "payos"
    suspend fun createPayment(req: CreatePaymentRequest): CreatedPayment  // payUrl + providerRef
    fun verifyWebhook(rawBody: String, headers: Map<String,String>): WebhookResult
    fun webhookAck(result: WebhookResult): HttpResponse   // {"code":"00"} / {"status":0} / 200
}
```

- Đăng ký qua `get`/map trong Ktor, route: `POST /api/payments/{provider}/webhook` — **ngoài `authenticate("auth-jwt")`**, public nhưng verify chữ ký.
- Secret config trong `application.conf` (`payment.vnpay.tmn-code`, `payment.momo.secretKey`...), không hardcode.

### 3.2 Data model mới (Exposed)

```kotlin
object Payments : Table("payments") {
    val id = uuid("id")
    val orderId = uuid("order_id")
    val provider = text("provider")            // vnpay|momo|zalopay|payos
    val amount = decimal("amount", 14, 2)
    val status = text("status").default("pending")  // pending|processing|paid|failed|expired|refunded
    val providerOrderId = text("provider_order_id").uniqueIndex()  // id mình gửi gateway
    val providerTxnId = text("provider_txn_id").uniqueIndex().nullable()
    val rawWebhook = text("raw_webhook").nullable()
    val paidAt = timestampWithTimeZone("paid_at").nullable()
    val createdAt/updatedAt = ...
}
```

- `Orders.paymentStatus` mở rộng: `unpaid → processing → paid | failed | refunded` (thêm 2 giá trị, enum Flutter map tương ứng).
- `provider_order_id` = `<orderId suffix><timestamp>` để truy vết 2 chiều.

### 3.3 API mới

| Method | Path | Auth | Mô tả |
|---|---|---|---|
| POST | `/api/orders/{id}/payment` | JWT | body `{provider}` → tạo payment record (server tính amount từ DB), ký, trả `{payUrl, providerOrderId}` |
| POST | `/api/payments/{provider}/webhook` | chữ ký | verify → update `payments.status` + `orders.payment_status` |
| GET | `/api/orders/{id}` | JWT | đã có — client **poll** endpoint này mỗi ~2s, timeout 60s sau khi về app |

### 3.4 Flutter side

- **Không cần SDK native.** Cả 4 cổng đều hoạt động được chỉ với URL + WebView → tránh dependency rác.
- `dio` đã có; ký request (nếu tích hợp app-to-app MoMo/ZaloPay sau này) dùng package `crypto` — **cần thêm vào pubspec**.
- Mở `payUrl`: dùng `url_launcher` (launch in app browser / custom tab) hoặc `webview_flutter` chặn redirect `redirectUrl` để đóng sớm. Android 11+ khai báo `<queries>` cho intent `momo://`, `zalopay://` nếu làm app-to-app.
- Source of truth = poll `GET /api/orders/{id}` → `paymentStatus == paid` thì điều hướng `/order-success`. Không đổi trạng thái từ `returnUrl`.
- Checkout screen: thay `_payOption('bank', ...)` mock bằng danh sách provider động (backend trả `GET /api/payment/providers` — hỗ trợ bật/tắt từng cổng không cần release app).

---

## 4. Lộ trình từng bước

### Phase 0 — Chốt hạ tầng (0,5 ngày)
- Đăng ký tài khoản sandbox: chọn **PayOS hoặc MoMo làm cổng đầu tiên** (đ_docs + sandbox mở ngay, không cần hợp đồng giấy để test). VNPAY cần TMN code từ NH.
- Thêm `crypto` vào app; thêm cấu hình `payment.*` vào `application.conf`.

### Phase 1 — Cột sống thanh toán QR (2–3 ngày)
1. `Payments` table + mapper + migration (`SchemaUtils.create` đang chạy auto — kiểm tra `DatabaseFactory`).
2. `PaymentProvider` interface + **1 implementation** (khuyến nghị PayOS: 1 lệnh gọi API, JSON, HMAC-SHA256, webhook có retry sẵn).
3. `POST /api/orders/{id}/payment` + `POST /api/payments/payos/webhook`.
4. Flutter: checkout gọi API → mở `checkoutUrl` → poll → success screen đổi trạng thái thật.
5. Test: ký/verify bằng assert nhỏ trong `test/` backend; simulate webhook bằng curl.

### Phase 2 — Thêm cổng (2 ngày/cổng)
- MoMo + ZaloPay theo interface có sẵn. Thêm `GET /api/payment/providers`.
- deep link app-to-app (tuỳ chọn, UX nhanh hơn WebView).

### Phase 3 — CK ngân hàng tự động (khi cần)
- Hiện tại chọn `bank_transfer` = mã hoá ghi chú chuyển khoản thủ công. 2PAY/9Pay generate virtual account theo `orderId`, webhook báo tự động `paid` — đáng làm vì cây cảnh đơn 2–10tr, khách quen CK.

### Phase 4 — Refund đối soát
- `refunded` status + trang admin đối soát (backend đã có swagger + SDUI admin).

---

## 5. Checklist an toàn (bắt buộc trước production)

- [ ] Webhook **không** nằm sau JWT; verify chữ ký trước khi parse payload
- [ ] Amount đối chiếu từ DB, reject nếu lệnh webhook khác quá dung sai 0đ
- [ ] `payments.provider_txn_id` unique → chống webhook lặp
- [ ] Secret keys chỉ nằm server; app **không bao giờ** giữ secretKey
- [ ] Timeout `processing` → job phụ hết hạn payment (15 phút, theo gateway)
- [ ] Log `raw_webhook` để replay/đối soát khi tranh chấp
- [ ] HTTPS cho IPN URL (mọi gateway đều đòi)
- [ ] TMĐT thông báo/bộ Công Thương; dùng tổ chức trung gian có giấy phép NHNN

## 6. Câu hỏi mở (cần quyết)

1. Ví chính của khách mục tiêu: MoMo hay ZaloPay hay ShopeePay? (quyết định cổng priority 2)
2. Có chấp nhận chờ hợp đồng VNPAY qua NH, hay khởi đầu bằng PayOS để đi nhanh?
3. COD vẫn là phương thức chính (cây cảnh sợ vận chuyển hỏng) — giới hạn COD theo giá trị đơn?
