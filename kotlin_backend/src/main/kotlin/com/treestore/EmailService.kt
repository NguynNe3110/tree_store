package com.treestore

import java.util.Properties
import javax.mail.*
import javax.mail.internet.*

// ponytail: hardcoded SMTP via javax.mail. upgrade to ktor-mail or SendGrid when production
object EmailService {
    private val host = System.getenv("SMTP_HOST") ?: "smtp.gmail.com"
    private val port = (System.getenv("SMTP_PORT") ?: "587").toInt()
    private val user = System.getenv("SMTP_USER") ?: ""
    private val pass = System.getenv("SMTP_PASS") ?: ""
    private val from = System.getenv("SMTP_FROM") ?: user

    fun sendOtp(email: String, code: String) {
        if (user.isEmpty() || pass.isEmpty()) {
            println("[EmailService] SMTP not configured. OTP for $email: $code")
            return
        }
        val props = Properties().apply {
            put("mail.smtp.auth", "true")
            put("mail.smtp.starttls.enable", "true")
            put("mail.smtp.host", host)
            put("mail.smtp.port", port.toString())
        }
        val session = Session.getInstance(props, object : Authenticator() {
            override fun getPasswordAuthentication() = PasswordAuthentication(user, pass)
        })
        val msg = MimeMessage(session).apply {
            setFrom(InternetAddress(from))
            setRecipients(Message.RecipientType.TO, InternetAddress.parse(email))
            subject = "Ma xac thuc TreeStore"
            setText("Ma OTP cua ban la: $code\nHieu luc trong 5 phut.")
        }
        Transport.send(msg)
    }
}

</parameter>