package com.treestore

import io.ktor.server.config.*
import java.util.Properties
import javax.mail.*
import javax.mail.internet.*

// ponytail: hardcoded SMTP via javax.mail. upgrade to ktor-mail or SendGrid when production
object EmailService {
    private var host = "smtp.gmail.com"
    private var port = 587
    private var user = ""
    private var pass = ""
    private var senderEmail = ""

    fun init(config: ApplicationConfig) {
        host = config.propertyOrNull("smtp.host")?.getString() ?: host
        port = config.propertyOrNull("smtp.port")?.getString()?.toIntOrNull() ?: port
        user = config.propertyOrNull("smtp.user")?.getString() ?: user
        pass = config.propertyOrNull("smtp.password")?.getString() ?: pass
        senderEmail = config.propertyOrNull("smtp.from")?.getString() ?: user
    }

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
            setFrom(InternetAddress(senderEmail))
            setRecipient(Message.RecipientType.TO, InternetAddress(email))
            subject = "Ma xac thuc TreeStore"
            setText("Ma OTP cua ban la: $code\nHieu luc trong 5 phut.")
        }
        Transport.send(msg)
    }
}