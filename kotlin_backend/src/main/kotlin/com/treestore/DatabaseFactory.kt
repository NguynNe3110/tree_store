package com.treestore

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.server.config.*
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.transactions.transaction

object DatabaseFactory {
    fun init(config: ApplicationConfig) {
        val hikariConfig = HikariConfig().apply {
            jdbcUrl = config.property("db.jdbcUrl").getString()
            driverClassName = config.property("db.driverClassName").getString()
            username = config.property("db.user").getString()
            password = config.property("db.password").getString()
            maximumPoolSize = config.property("db.maximumPoolSize").getString().toInt()
            isAutoCommit = false
            transactionIsolation = "TRANSACTION_REPEATABLE_READ"
            validate()
        }
        Database.connect(HikariDataSource(hikariConfig))

        transaction {
            SchemaUtils.createMissingTablesAndColumns(
                Profiles,
                Categories,
                Trees,
                TreeImages,
                CartItems,
                Addresses,
                Orders,
                OrderItems,
                Payments,
                RefreshTokens,
                OtpCodes,
                UiBlocks
            )
        }
    }
}
