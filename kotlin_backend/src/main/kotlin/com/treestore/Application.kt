package com.treestore

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.auth.basic
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.response.*
import io.ktor.server.http.content.*
import io.ktor.server.routing.*
import io.github.smiley4.ktoropenapi.*
import io.github.smiley4.ktoropenapi.config.*
import io.github.smiley4.ktorswaggerui.*
import kotlinx.serialization.json.Json
import com.treestore.routes.*

 fun main(args: Array<String>) {
     EngineMain.main(args)
}

fun Application.module() {
    DatabaseFactory.init(environment.config)
    EmailService.init(environment.config)
    SeedData.seedIfEmpty()
    SeedData.backfillImages()

    val jwtSecret = environment.config.property("jwt.secret").getString()
    val jwtIssuer = environment.config.property("jwt.issuer").getString()
    val jwtAudience = environment.config.property("jwt.audience").getString()
    val jwtRealm = environment.config.property("jwt.realm").getString()
    val adminUser = environment.config.property("admin.username").getString()
    val adminPass = environment.config.property("admin.password").getString()

    install(ContentNegotiation) {
        json(Json {
            prettyPrint = true
            isLenient = true
            ignoreUnknownKeys = true
            encodeDefaults = true
        })
    }

    install(StatusPages) {
        exception<Throwable> { call, cause ->
            call.respondText("Internal Server Error: ${cause.localizedMessage}", status = io.ktor.http.HttpStatusCode.InternalServerError)
        }
    }

    install(Authentication) {
        jwt("auth-jwt") {
            realm = jwtRealm
            verifier(
                JWT.require(Algorithm.HMAC256(jwtSecret))
                    .withIssuer(jwtIssuer)
                    .withAudience(jwtAudience)
                    .build()
            )
            validate { credential ->
                if (credential.payload.getClaim("userId").asString() != null) {
                    JWTPrincipal(credential.payload)
                } else null
            }
        }
        // ponytail: basic auth for SDUI admin dashboard, no hashing for MVP. add bcrypt when production
        basic("admin-basic") {
            realm = "SDUI Admin"
            validate { credentials ->
                if (credentials.name == adminUser && credentials.password == adminPass)
                    UserIdPrincipal(credentials.name)
                else null
            }
        }
    }

    // ponytail: OpenApi + Swagger UI for dev only, remove when production
    install(OpenApi) {
        info {
            title = "Tree Store API"
            version = "1.0.0"
        }
    }

    routing {
        route("api.json") {
            openApi()
        }
        route("swagger") {
            swaggerUI("/api.json")
        }

        authRoutes(jwtSecret, jwtIssuer, jwtAudience)
        otpRoutes()
        homeRoutes()
        authenticate("admin-basic") {
            adminSduiRoutes()
        }
        categoryRoutes()
        treeRoutes()
        cartRoutes()
        orderRoutes()
        profileRoutes()
        // ponytail: serve SDUI dashboard HTML for MVP
        static("/") {
            resources("static")
        }
    }
}
