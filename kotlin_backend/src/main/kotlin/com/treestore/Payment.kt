package com.treestore

import java.net.URI
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.security.MessageDigest
import java.time.Duration
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
import kotlinx.serialization.json.*

data class CreatedPayment(
    val providerPaymentId: String?,
    val orderCode: Long,
    val checkoutUrl: String
)

data class WebhookResult(
    val verified: Boolean,
    val success: Boolean,
    val orderCode: Long?,
    val transactionNo: String?,
    val providerPaymentId: String?,
    val amount: Long,
    val raw: String
)

abstract class PaymentProvider {
    abstract val code: String
    abstract fun createPayment(
        orderCode: Long,
        amount: Long,
        description: String,
        returnUrl: String,
        cancelUrl: String
    ): CreatedPayment

    abstract fun verifyWebhook(body: String, signature: String?): WebhookResult

    // body ACK that every VN gateway expects; subclasses override shape
    open val webhookAckBody: String = """{"code":"00","desc":"Success"}"""
}

fun hmac(secret: String, data: String, algorithm: String): String {
    val mac = Mac.getInstance(algorithm)
    mac.init(SecretKeySpec(secret.toByteArray(Charsets.UTF_8), algorithm))
    return mac.doFinal(data.toByteArray(Charsets.UTF_8)).joinToString("") { "%02x".format(it) }
}

fun hmacSha256(secret: String, data: String) = hmac(secret, data, "HmacSHA256")
fun hmacSha512(secret: String, data: String) = hmac(secret, data, "HmacSHA512")

fun secureCompare(a: String, b: String): Boolean =
    MessageDigest.isEqual(a.lowercase().toByteArray(), b.lowercase().toByteArray())

// ponytail: PayOS v2 contract (payment-requests + x-signature webhook). Verify field names
// against sandbox keys before production. Upgrade path: MoMo/ZaloPay providers here.
class PayOsProvider(
    private val baseUrl: String,
    private val clientId: String,
    private val checksumSecret: String,
    private val secretKey: String
) : PaymentProvider() {
    override val code = "payos"

    private val client: HttpClient = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(10))
        .build()
    private val json = Json { ignoreUnknownKeys = true }

    override fun createPayment(
        orderCode: Long,
        amount: Long,
        description: String,
        returnUrl: String,
        cancelUrl: String
    ): CreatedPayment {
        val payload = buildJsonObject {
            put("amount", amount)
            put("appId", clientId)
            put("orderCode", orderCode)
            put("orderDescription", description.take(25))
            put("browserLanguage", "vn")
            put("returnUrl", returnUrl)
            put("cancelUrl", cancelUrl)
        }.toString()
        val request = HttpRequest.newBuilder()
            .uri(URI.create("$baseUrl/v2/payment-requests"))
            .timeout(Duration.ofSeconds(15))
            .header("Content-Type", "application/json")
            .header("apikey", clientId)
            .header("signature", hmacSha256(checksumSecret, payload))
            .POST(HttpRequest.BodyPublishers.ofString(payload))
            .build()
        val response = client.send(request, HttpResponse.BodyHandlers.ofString())
        val root = json.parseToJsonElement(response.body()).jsonObject
        if (response.statusCode() !in 200..299 || root["data"] == null) {
            throw IllegalStateException("PayOS create failed ${response.statusCode()}: ${root["msg"] ?: response.body()}")
        }
        val data = root["data"]!!.jsonObject
        return CreatedPayment(
            providerPaymentId = (data["paymentLinkId"] ?: data["id"])?.jsonPrimitive?.contentOrNull,
            orderCode = data["orderCode"]?.jsonPrimitive?.long ?: orderCode,
            checkoutUrl = data["checkoutUrl"]!!.jsonPrimitive.content
        )
    }

    override fun verifyWebhook(body: String, signature: String?): WebhookResult {
        val invalid = WebhookResult(false, false, null, null, null, 0, body)
        if (signature == null || !secureCompare(hmacSha512(secretKey, body), signature)) return invalid
        val data = json.parseToJsonElement(body).jsonObject["data"]?.jsonObject ?: return invalid
        val orderCode = data["orderCode"]?.jsonPrimitive?.longOrNull ?: return invalid
        val payments = data["payments"]?.jsonArray?.firstOrNull()?.jsonObject
        return WebhookResult(
            verified = true,
            success = data["code"]?.jsonPrimitive?.contentOrNull == "00" &&
                (payments?.get("businessResult")?.jsonPrimitive?.contentOrNull ?: "OK") == "OK",
            orderCode = orderCode,
            transactionNo = payments?.get("outTransactionId")?.jsonPrimitive?.contentOrNull,
            providerPaymentId = data["id"]?.jsonPrimitive?.contentOrNull,
            amount = data["amount"]?.jsonPrimitive?.long ?: 0,
            raw = body
        )
    }
}
