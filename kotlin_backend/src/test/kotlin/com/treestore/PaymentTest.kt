package com.treestore

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class PaymentTest {
    private val provider = PayOsProvider("https://api.payos.vn", "cid", "checksum", "webhooksecret")

    @Test
    fun `hmac vectors match known values`() {
        // known HMAC-SHA256 test vector
        assertEquals(
            "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8",
            hmacSha256("key", "The quick brown fox jumps over the lazy dog")
        )
        assertTrue(secureCompare("ABC", "abc"))
        assertFalse(secureCompare("abc", "abd"))
    }

    @Test
    fun `valid webhook signature verifies success payload`() {
        val body = """{"data":{"code":"00","id":"plt_1","amount":100000,"orderCode":123,"payments":[{"outTransactionId":"ot_9","businessResult":"OK"}]}}"""
        val sig = hmacSha512("webhooksecret", body)
        val r = provider.verifyWebhook(body, sig)
        assertTrue(r.verified)
        assertTrue(r.success)
        assertEquals(123L, r.orderCode)
        assertEquals(100000L, r.amount)
        assertEquals("ot_9", r.transactionNo)
    }

    @Test
    fun `tampered body or bad signature rejected`() {
        val body = """{"data":{"code":"00","orderCode":123,"amount":100000}}"""
        val sig = hmacSha512("webhooksecret", body)
        assertFalse(provider.verifyWebhook(body.replace("123", "999"), sig).verified)
        assertFalse(provider.verifyWebhook(body, "deadbeef").verified)
        assertFalse(provider.verifyWebhook(body, null).verified)
    }

    @Test
    fun `failed code webhook is verified but not success`() {
        val body = """{"data":{"code":"11","orderCode":123,"amount":100000,"cancel":true,"payments":[]}}"""
        val r = provider.verifyWebhook(body, hmacSha512("webhooksecret", body))
        assertTrue(r.verified)
        assertFalse(r.success)
    }
}
