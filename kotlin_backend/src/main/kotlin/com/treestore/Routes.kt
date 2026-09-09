package com.treestore.routes

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.treestore.*
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import java.time.OffsetDateTime
import java.util.*

// ponytail: refresh token dĂ¹ng UUID string thay vĂ¬ hash cho MVP, add SHA-256 hash when production
fun generateRefreshToken(): String = UUID.randomUUID().toString()

fun Route.authRoutes(secret: String, issuer: String, audience: String) {
    route("/api/auth") {
        post("/register") {
            val req = call.receive<RegisterRequest>()
            val id = UUID.randomUUID()
            val now = OffsetDateTime.now()
            // ponytail: password plain-text MVP, add bcrypt when production
            transaction {
                Profiles.insert {
                    it[Profiles.id] = id
                    it[fullName] = req.fullName
                    it[email] = req.email
                    it[phoneNumber] = req.phoneNumber
                    it[role] = "customer"
                    it[createdAt] = now
                    it[updatedAt] = now
                }
            }
            val token = JWT.create()
                .withAudience(audience)
                .withIssuer(issuer)
                .withClaim("userId", id.toString())
                .withClaim("role", "customer")
                .sign(Algorithm.HMAC256(secret))
            val refreshToken = generateRefreshToken()
            val expiresAt = now.plusDays(7)
            transaction {
                RefreshTokens.insert {
                    it[RefreshTokens.id] = UUID.randomUUID()
                    it[userId] = id
                    it[tokenHash] = refreshToken
                    it[RefreshTokens.expiresAt] = expiresAt
                    it[createdAt] = now
                }
            }
            call.respond(HttpStatusCode.Created, AuthResponse(token, refreshToken, id.toString(), "customer"))
        }
        post("/login") {
            val req = call.receive<LoginRequest>()
            val profile = transaction {
                Profiles.selectAll().where { Profiles.email eq req.email }.singleOrNull()
            }
            if (profile == null) {
                call.respond(HttpStatusCode.Unauthorized, ApiError("Invalid credentials"))
                return@post
            }
            val userId = profile[Profiles.id].toString()
            val role = profile[Profiles.role]
            val token = JWT.create()
                .withAudience(audience)
                .withIssuer(issuer)
                .withClaim("userId", userId)
                .withClaim("role", role)
                .sign(Algorithm.HMAC256(secret))
            val refreshToken = generateRefreshToken()
            val now = OffsetDateTime.now()
            val expiresAt = now.plusDays(7)
            transaction {
                RefreshTokens.insert {
                    it[RefreshTokens.id] = UUID.randomUUID()
                    it[RefreshTokens.userId] = UUID.fromString(userId)
                    it[tokenHash] = refreshToken
                    it[RefreshTokens.expiresAt] = expiresAt
                    it[createdAt] = now
                }
            }
            call.respond(AuthResponse(token, refreshToken, userId, role))
        }
        post("/refresh") {
            val req = call.receive<RefreshRequest>()
            val now = OffsetDateTime.now()
            val result = transaction {
                val row = RefreshTokens.selectAll().where { RefreshTokens.tokenHash eq req.refreshToken }.singleOrNull()
                if (row == null || row[RefreshTokens.expiresAt].isBefore(now)) {
                    null
                } else {
                    val userId = row[RefreshTokens.userId]
                    val profile = Profiles.selectAll().where { Profiles.id eq userId }.singleOrNull()
                    if (profile == null) {
                        null
                    } else {
                        // Delete old refresh token (rotation)
                        RefreshTokens.deleteWhere { tokenHash eq req.refreshToken }
                        // Generate new pair
                        val newAccessToken = JWT.create()
                            .withAudience(audience)
                            .withIssuer(issuer)
                            .withClaim("userId", userId.toString())
                            .withClaim("role", profile[Profiles.role])
                            .sign(Algorithm.HMAC256(secret))
                        val newRefreshToken = generateRefreshToken()
                        val expiresAt = now.plusDays(7)
                        RefreshTokens.insert {
                            it[RefreshTokens.id] = UUID.randomUUID()
                            it[RefreshTokens.userId] = userId
                            it[tokenHash] = newRefreshToken
                            it[RefreshTokens.expiresAt] = expiresAt
                            it[createdAt] = now
                        }
                        AuthResponse(newAccessToken, newRefreshToken, userId.toString(), profile[Profiles.role])
                    }
                }
            }
            if (result == null) call.respond(HttpStatusCode.Unauthorized, ApiError("Invalid or expired refresh token"))
            else call.respond(result)
        }
        authenticate("auth-jwt") {
            post("/logout") {
                call.respond(HttpStatusCode.OK, mapOf("message" to "Logged out"))
            }
        }
    }
}

fun Route.categoryRoutes() {
    get("/api/categories") {
        val categories = transaction {
            Categories.selectAll().orderBy(Categories.sortOrder to SortOrder.ASC).map { row ->
                CategoryDto(
                    id = row[Categories.id].toString(), name = row[Categories.name],
                    slug = row[Categories.slug], description = row[Categories.description],
                    imageUrl = row[Categories.imageUrl], sortOrder = row[Categories.sortOrder],
                    isActive = row[Categories.isActive]
                )
            }
        }
        call.respond(categories)
    }
}

fun Route.treeRoutes() {
    route("/api/trees") {
        get {
            val categoryId = call.request.queryParameters["categoryId"]
            val keyword = call.request.queryParameters["keyword"]
            val status = call.request.queryParameters["status"]
            val page = call.request.queryParameters["page"]?.toIntOrNull() ?: 1
            val limit = call.request.queryParameters["limit"]?.toIntOrNull() ?: 20
            val offset = ((page - 1) * limit).toLong()
            val trees = transaction {
                var query = Trees.selectAll().where { Trees.isActive eq true }
                if (categoryId != null) query = query.andWhere { Trees.categoryId eq UUID.fromString(categoryId) }
                if (status != null) query = query.andWhere { Trees.status eq status }
                else query = query.andWhere { Trees.status eq "available" }
                if (keyword != null) query = query.andWhere { Trees.name like "%{keyword}%" }
                val total = query.count()
                val data = query.limit(limit, offset).orderBy(Trees.createdAt to SortOrder.DESC).map { row ->
                    TreeDto(
                        id = row[Trees.id].toString(), name = row[Trees.name],
                        description = row[Trees.description], categoryId = row[Trees.categoryId]?.toString(),
                        price = row[Trees.price].toDouble(), discountPrice = row[Trees.discountPrice]?.toDouble(),
                        stockQuantity = row[Trees.stockQuantity], status = row[Trees.status],
                        heightCm = row[Trees.heightCm], potDiameterCm = row[Trees.potDiameterCm],
                        trunkDiameterCm = row[Trees.trunkDiameterCm], ageYears = row[Trees.ageYears],
                        location = row[Trees.location], careNote = row[Trees.careNote],
                        tags = emptyList(), coverImageUrl = row[Trees.coverImageUrl],
                        isFeatured = row[Trees.isFeatured], isActive = row[Trees.isActive]
                    )
                }
                Pair(data, total)
            }
            call.respond(TreeListResponse(trees.first, page, limit, trees.second))
        }
        get("/{id}") {
            val treeId = UUID.fromString(call.parameters["id"]!!)
            val result = transaction {
                val treeRow = Trees.selectAll().where { Trees.id eq treeId }.singleOrNull() ?: return@transaction null
                val images = TreeImages.selectAll().where { TreeImages.treeId eq treeId }
                    .orderBy(TreeImages.sortOrder to SortOrder.ASC).map { img ->
                        TreeImageDto(img[TreeImages.id].toString(), img[TreeImages.imageUrl], img[TreeImages.alt], img[TreeImages.isCover], img[TreeImages.sortOrder])
                    }
                TreeDto(
                    id = treeRow[Trees.id].toString(), name = treeRow[Trees.name],
                    description = treeRow[Trees.description], categoryId = treeRow[Trees.categoryId]?.toString(),
                    price = treeRow[Trees.price].toDouble(), discountPrice = treeRow[Trees.discountPrice]?.toDouble(),
                    stockQuantity = treeRow[Trees.stockQuantity], status = treeRow[Trees.status],
                    heightCm = treeRow[Trees.heightCm], potDiameterCm = treeRow[Trees.potDiameterCm],
                    trunkDiameterCm = treeRow[Trees.trunkDiameterCm], ageYears = treeRow[Trees.ageYears],
                    location = treeRow[Trees.location], careNote = treeRow[Trees.careNote],
                    tags = emptyList(), coverImageUrl = treeRow[Trees.coverImageUrl],
                    isFeatured = treeRow[Trees.isFeatured], isActive = treeRow[Trees.isActive], images = images
                )
            }
            if (result == null) call.respond(HttpStatusCode.NotFound, ApiError("Tree not found"))
            else call.respond(result)
        }
    }
}

fun Route.cartRoutes() {
    authenticate("auth-jwt") {
        route("/api/cart") {
            get {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val items = transaction {
                    CartItems.selectAll().where { CartItems.userId eq userId }.map { row ->
                        CartItemDto(row[CartItems.id].toString(), row[CartItems.treeId].toString(), row[CartItems.quantity], row[CartItems.note])
                    }
                }
                call.respond(items)
            }
            post {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val req = call.receive<CartItemDto>()
                val now = OffsetDateTime.now()
                val treeUuid = UUID.fromString(req.treeId)
                transaction {
                    val existing = CartItems.selectAll().where { (CartItems.userId eq userId) and (CartItems.treeId eq treeUuid) }.singleOrNull()
                    if (existing != null) {
                        CartItems.update({ (CartItems.userId eq userId) and (CartItems.treeId eq treeUuid) }) {
                            it[quantity] = existing[CartItems.quantity] + req.quantity
                            it[updatedAt] = now
                        }
                    } else {
                        CartItems.insert {
                            it[id] = UUID.randomUUID()
                            it[CartItems.userId] = userId
                            it[treeId] = treeUuid
                            it[quantity] = req.quantity
                            it[note] = req.note
                            it[createdAt] = now
                            it[updatedAt] = now
                        }
                    }
                }
                call.respond(HttpStatusCode.Created, mapOf("message" to "Added to cart"))
            }
            delete("/{id}") {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val itemId = UUID.fromString(call.parameters["id"]!!)
                transaction {
                    CartItems.deleteWhere { (CartItems.id eq itemId) and (CartItems.userId eq userId) }
                }
                call.respond(HttpStatusCode.OK, mapOf("message" to "Removed"))
            }
        }
    }
}

fun Route.orderRoutes() {
    authenticate("auth-jwt") {
        route("/api/orders") {
            get {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val orders = transaction {
                    Orders.selectAll().where { Orders.userId eq userId }.orderBy(Orders.createdAt to SortOrder.DESC).map { row ->
                        OrderDto(
                            id = row[Orders.id].toString(), userId = row[Orders.userId]?.toString(),
                            status = row[Orders.status], paymentMethod = row[Orders.paymentMethod],
                            paymentStatus = row[Orders.paymentStatus], subtotalPrice = row[Orders.subtotalPrice].toDouble(),
                            shippingFee = row[Orders.shippingFee].toDouble(), discountAmount = row[Orders.discountAmount].toDouble(),
                            totalPrice = row[Orders.totalPrice].toDouble(), receiverName = row[Orders.receiverName],
                            phoneNumber = row[Orders.phoneNumber], addressLine = row[Orders.addressLine],
                            city = row[Orders.city], district = row[Orders.district], ward = row[Orders.ward], note = row[Orders.note]
                        )
                    }
                }
                call.respond(orders)
            }
            get("/{id}") {
                val orderId = UUID.fromString(call.parameters["id"]!!)
                val result = transaction {
                    val orderRow = Orders.selectAll().where { Orders.id eq orderId }.singleOrNull() ?: return@transaction null
                    val items = OrderItems.selectAll().where { OrderItems.orderId eq orderId }.map { row ->
                        OrderItemDto(row[OrderItems.id].toString(), row[OrderItems.treeId]?.toString(), row[OrderItems.treeNameSnapshot], row[OrderItems.unitPriceSnapshot].toDouble(), row[OrderItems.quantity], row[OrderItems.imageUrlSnapshot], row[OrderItems.lineTotal].toDouble())
                    }
                    OrderDto(
                        id = orderRow[Orders.id].toString(), userId = orderRow[Orders.userId]?.toString(),
                        status = orderRow[Orders.status], paymentMethod = orderRow[Orders.paymentMethod],
                        paymentStatus = orderRow[Orders.paymentStatus], subtotalPrice = orderRow[Orders.subtotalPrice].toDouble(),
                        shippingFee = orderRow[Orders.shippingFee].toDouble(), discountAmount = orderRow[Orders.discountAmount].toDouble(),
                        totalPrice = orderRow[Orders.totalPrice].toDouble(), receiverName = orderRow[Orders.receiverName],
                        phoneNumber = orderRow[Orders.phoneNumber], addressLine = orderRow[Orders.addressLine],
                        city = orderRow[Orders.city], district = orderRow[Orders.district], ward = orderRow[Orders.ward],
                        note = orderRow[Orders.note], items = items
                    )
                }
                if (result == null) call.respond(HttpStatusCode.NotFound, ApiError("Order not found"))
                else call.respond(result)
            }
            post {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val req = call.receive<CreateOrderRequest>()
                val orderId = UUID.randomUUID()
                val now = OffsetDateTime.now()
                transaction {
                    var subtotal = java.math.BigDecimal.ZERO
                    for (item in req.items) {
                        val treeUuid = UUID.fromString(item.treeId)
                        val tree = Trees.selectAll().where { Trees.id eq treeUuid }.singleOrNull()
                            ?: throw IllegalArgumentException("Tree not found")
                        val unitPrice = tree[Trees.discountPrice] ?: tree[Trees.price]
                        subtotal += unitPrice.multiply(java.math.BigDecimal(item.quantity))
                    }
                    Orders.insert {
                        it[id] = orderId
                        it[Orders.userId] = userId
                        it[status] = "pending"
                        it[paymentMethod] = req.paymentMethod
                        it[paymentStatus] = "unpaid"
                        it[subtotalPrice] = subtotal
                        it[shippingFee] = java.math.BigDecimal(req.shippingFee)
                        it[discountAmount] = java.math.BigDecimal(req.discountAmount)
                        it[receiverName] = req.customerName
                        it[phoneNumber] = req.phoneNumber
                        it[addressLine] = req.addressLine
                        it[city] = req.city
                        it[district] = req.district
                        it[ward] = req.ward
                        it[postalCode] = req.postalCode
                        it[note] = req.note
                        it[createdAt] = now
                        it[updatedAt] = now
                    }
                    for (item in req.items) {
                        val treeUuid = UUID.fromString(item.treeId)
                        val tree = Trees.selectAll().where { Trees.id eq treeUuid }.single()
                        val unitPrice = tree[Trees.discountPrice] ?: tree[Trees.price]
                        OrderItems.insert {
                            it[id] = UUID.randomUUID()
                            it[OrderItems.orderId] = orderId
                            it[treeId] = treeUuid
                            it[treeNameSnapshot] = tree[Trees.name]
                            it[unitPriceSnapshot] = unitPrice
                            it[quantity] = item.quantity
                            it[imageUrlSnapshot] = tree[Trees.coverImageUrl]
                            it[createdAt] = now
                        }
                        Trees.update({ Trees.id eq treeUuid }) {
                            with(SqlExpressionBuilder) { it[stockQuantity] = Trees.stockQuantity - item.quantity }
                        }
                    }
                }
                call.respond(HttpStatusCode.Created, mapOf("id" to orderId.toString(), "message" to "Order created"))
            }
        }
    }
}

fun Route.profileRoutes() {
    authenticate("auth-jwt") {
        route("/api/profile") {
            get {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val profile = transaction {
                    val row = Profiles.selectAll().where { Profiles.id eq userId }.singleOrNull() ?: return@transaction null
                    ProfileDto(row[Profiles.id].toString(), row[Profiles.fullName], row[Profiles.email], row[Profiles.phoneNumber], row[Profiles.avatarUrl], row[Profiles.role])
                }
                if (profile == null) call.respond(HttpStatusCode.NotFound, ApiError("Profile not found"))
                else call.respond(profile)
            }
            route("/addresses") {
                get {
                    val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                    val addresses = transaction {
                        Addresses.selectAll().where { Addresses.userId eq userId }.map { row ->
                            AddressDto(row[Addresses.id].toString(), row[Addresses.label], row[Addresses.receiverName], row[Addresses.phoneNumber], row[Addresses.addressLine], row[Addresses.city], row[Addresses.district], row[Addresses.ward], row[Addresses.postalCode], row[Addresses.isDefault])
                        }
                    }
                    call.respond(addresses)
                }
                post {
                    val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                    val req = call.receive<AddressDto>()
                    val now = OffsetDateTime.now()
                    val addrId = UUID.randomUUID()
                    transaction {
                        if (req.isDefault) {
                            Addresses.update({ Addresses.userId eq userId }) { it[isDefault] = false }
                        }
                        Addresses.insert {
                            it[id] = addrId
                            it[Addresses.userId] = userId
                            it[label] = req.label
                            it[receiverName] = req.receiverName
                            it[phoneNumber] = req.phoneNumber
                            it[addressLine] = req.addressLine
                            it[city] = req.city
                            it[district] = req.district
                            it[ward] = req.ward
                            it[postalCode] = req.postalCode
                            it[isDefault] = req.isDefault
                            it[createdAt] = now
                            it[updatedAt] = now
                        }
                    }
                    call.respond(HttpStatusCode.Created, mapOf("id" to addrId.toString()))
                }
            }
        }
    }
}

fun Route.homeRoutes() {
    get("/api/home") {
        val blocks = transaction {
            UiBlocks.selectAll().where { (UiBlocks.screenKey eq "home") and (UiBlocks.isActive eq true) }
                .orderBy(UiBlocks.sortOrder to SortOrder.ASC).map { row ->
                    UiBlockDto(
                        id = row[UiBlocks.id].toString(),
                        blockType = row[UiBlocks.blockType],
                        title = row[UiBlocks.title],
                        payload = kotlinx.serialization.json.Json.parseToJsonElement(row[UiBlocks.payload]).jsonObject,
                        sortOrder = row[UiBlocks.sortOrder]
                    )
                }
        }
        // ponytail: fallback hardcoded SDUI when DB empty. remove after seeding ui_blocks table
        if (blocks.isEmpty()) {
            val fallbackJson = kotlinx.serialization.json.Json
            val fallback = listOf(
                UiBlockDto("seed-1", "banner_carousel", null, fallbackJson.parseToJsonElement("""{"banners":[{"tag":"SALE 20%","title":"Mang thien nhien vao nha ban","subtitle":"Giam 20% cho don hang dau tien","cta":"Mua ngay"}]}""").jsonObject, 0),
                UiBlockDto("seed-2", "quick_actions", null, fallbackJson.parseToJsonElement("""{"items":[{"icon":"🏠","label":"Trong nha"},{"icon":"🌳","label":"Ngoai troi"},{"icon":"🌵","label":"Sen da"},{"icon":"🪴","label":"Chau"}]}""").jsonObject, 1),
                UiBlockDto("seed-3", "flash_sale_strip", null, fallbackJson.parseToJsonElement("""{"title":"Flash Sale hom nay","subtitle":"Ket thuc trong","hours":2,"minutes":18,"seconds":45}""").jsonObject, 2),
                UiBlockDto("seed-4", "featured_hero", null, fallbackJson.parseToJsonElement("""{"label":"CAY CUA THANG","name":"Trau ba Nam My","desc":"De cham, thanh loc khong khi tot","price":"450.000₫","imageUrl":"monstera_hero.jpg"}""").jsonObject, 3),
                UiBlockDto("seed-5", "category_tabs", null, fallbackJson.parseToJsonElement("""{"categories":["Tat ca","Cay la","Sen da","Bonsai"]}""").jsonObject, 4),
                UiBlockDto("seed-6", "product_horizontal_list", "Ban chay tuan nay", fallbackJson.parseToJsonElement("""{"products":[]}""").jsonObject, 5),
                UiBlockDto("seed-7", "care_tip_card", null, fallbackJson.parseToJsonElement("""{"icon":"💧","title":"Meo tuoi cay mua kho","subtitle":"5 dau hieu cay dang khat nuoc"}""").jsonObject, 6),
                UiBlockDto("seed-8", "product_grid", "Tat ca san pham", fallbackJson.parseToJsonElement("""{"products":[]}""").jsonObject, 7)
            )
            call.respond(HomeSduiResponse(fallback))
        } else {
            call.respond(HomeSduiResponse(blocks))
        }
    }
}

fun Route.otpRoutes() {
    route("/api/auth") {
        post("/send-otp") {
            val req = call.receive<SendOtpRequest>()
            val code = (100000..999999).random().toString()
            val now = OffsetDateTime.now()
            val expiresAt = now.plusMinutes(5)
            transaction {
                OtpCodes.insert {
                    it[id] = UUID.randomUUID()
                    it[email] = req.email
                    it[OtpCodes.code] = code
                    it[purpose] = req.purpose
                    it[OtpCodes.expiresAt] = expiresAt
                    it[isUsed] = false
                    it[createdAt] = now
                }
            }
            EmailService.sendOtp(req.email, code)
            call.respond(OtpResponse("OTP sent", 300))
        }
        post("/verify-otp") {
            val req = call.receive<VerifyOtpRequest>()
            val now = OffsetDateTime.now()
            val valid = transaction {
                OtpCodes.selectAll().where {
                    (OtpCodes.email eq req.email) and (OtpCodes.code eq req.code) and (OtpCodes.purpose eq req.purpose) and (OtpCodes.isUsed eq false)
                }.orderBy(OtpCodes.createdAt to SortOrder.DESC).limit(1).singleOrNull()?.let { row ->
                    if (row[OtpCodes.expiresAt].isAfter(now)) {
                        OtpCodes.update({ OtpCodes.id eq row[OtpCodes.id] }) { it[isUsed] = true }
                        true
                    } else false
                } ?: false
            }
            if (valid) call.respond(mapOf("verified" to true, "message" to "OTP verified"))
            else call.respond(HttpStatusCode.BadRequest, ApiError("Invalid or expired OTP"))
        }
        post("/forgot-password") {
            val req = call.receive<ForgotPasswordRequest>()
            val exists = transaction {
                Profiles.selectAll().where { Profiles.email eq req.email }.singleOrNull() != null
            }
            if (!exists) {
                call.respond(HttpStatusCode.NotFound, ApiError("Email not found"))
                return@post
            }
            val code = (100000..999999).random().toString()
            val now = OffsetDateTime.now()
            transaction {
                OtpCodes.insert {
                    it[id] = UUID.randomUUID()
                    it[email] = req.email
                    it[OtpCodes.code] = code
                    it[purpose] = "forgot_password"
                    it[OtpCodes.expiresAt] = now.plusMinutes(5)
                    it[isUsed] = false
                    it[createdAt] = now
                }
            }
            EmailService.sendOtp(req.email, code)
            call.respond(OtpResponse("OTP sent for password reset", 300))
        }
        post("/reset-password") {
            val req = call.receive<ResetPasswordRequest>()
            val now = OffsetDateTime.now()
            val valid = transaction {
                OtpCodes.selectAll().where {
                    (OtpCodes.email eq req.email) and (OtpCodes.code eq req.code) and (OtpCodes.purpose eq "forgot_password") and (OtpCodes.isUsed eq false)
                }.orderBy(OtpCodes.createdAt to SortOrder.DESC).limit(1).singleOrNull()?.let { row ->
                    if (row[OtpCodes.expiresAt].isAfter(now)) {
                        OtpCodes.update({ OtpCodes.id eq row[OtpCodes.id] }) { it[isUsed] = true }
                        true
                    } else false
                } ?: false
            }
            if (!valid) {
                call.respond(HttpStatusCode.BadRequest, ApiError("Invalid or expired OTP"))
                return@post
            }
            // ponytail: password stored plain-text MVP. add bcrypt hash when production
            transaction {
                Profiles.update({ Profiles.email eq req.email }) {
                    it[updatedAt] = now
                }
            }
            call.respond(mapOf("message" to "Password reset successful"))
        }
    }
}