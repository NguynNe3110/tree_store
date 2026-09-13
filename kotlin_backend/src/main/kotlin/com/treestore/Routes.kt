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
import io.ktor.http.content.*
import io.github.smiley4.ktoropenapi.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import kotlinx.serialization.json.jsonObject
import java.time.OffsetDateTime
import java.util.*

// ponytail: refresh token dĂ¹ng UUID string thay vĂ¬ hash cho MVP, add SHA-256 hash when production
fun generateRefreshToken(): String = UUID.randomUUID().toString()

fun Route.authRoutes(secret: String, issuer: String, audience: String) {
    route("/api/auth") {
        post("/register", {
            summary = "Register new user"
            request { body<RegisterRequest>() }
            response {
                code(HttpStatusCode.Created) { description = "User created, returns tokens" }
                code(HttpStatusCode.Conflict) { description = "Email already exists" }
            }
        }) {
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
        post("/login", {
            summary = "Login with email and password"
            request { body<LoginRequest>() }
            response {
                code(HttpStatusCode.OK) { description = "Login success, returns tokens" }
                code(HttpStatusCode.Unauthorized) { description = "Invalid credentials" }
            }
        }) {
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
        post("/refresh", {
            summary = "Refresh access token using refresh token"
            request { body<RefreshRequest>() }
            response {
                code(HttpStatusCode.OK) { description = "New tokens issued" }
                code(HttpStatusCode.Unauthorized) { description = "Invalid or expired refresh token" }
            }
        }) {
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
            post("/logout", {
                summary = "Logout current user"
                response {
                    code(HttpStatusCode.OK) { description = "Logged out successfully" }
                }
            }) {
                call.respond(HttpStatusCode.OK, mapOf("message" to "Logged out"))
            }
        }
    }
}

fun Route.categoryRoutes() {
    get("/api/categories", {
        summary = "List all categories"
        response {
            code(HttpStatusCode.OK) { description = "Category list" }
        }
    }) {
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
        get({
            summary = "List trees with optional filters"
            request {
                queryParameter<String>("categoryId")
                queryParameter<String>("keyword")
                queryParameter<String>("status")
                queryParameter<Int>("page")
                queryParameter<Int>("limit")
            }
            response {
                code(HttpStatusCode.OK) { description = "Paginated tree list" }
            }
        }) {
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
                if (keyword != null) query = query.andWhere { Trees.name.lowerCase() like "%${keyword.lowercase()}%" }
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

        get("/featured", {
            summary = "Get featured trees for suggestions"
            response {
                code(HttpStatusCode.OK) { description = "List of featured trees" }
            }
        }) {
            val trees = transaction {
                Trees.selectAll().where { (Trees.isActive eq true) and (Trees.isFeatured eq true) }
                    .orderBy(Trees.createdAt to SortOrder.DESC).limit(10).map { row ->
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
            }
            call.respond(trees)
        }

        get("/{id}", {
            summary = "Get tree detail by ID"
            request {
                pathParameter<String>("id")
            }
            response {
                code(HttpStatusCode.OK) { description = "Tree detail with images" }
                code(HttpStatusCode.NotFound) { description = "Tree not found" }
            }
        }) {
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
            get({
                summary = "Get current user cart items"
                response {
                    code(HttpStatusCode.OK) { description = "Cart item list" }
                }
            }) {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val items = transaction {
                    CartItems.selectAll().where { CartItems.userId eq userId }.map { row ->
                        val treeId = row[CartItems.treeId]
                        val treeRow = Trees.selectAll().where { Trees.id eq treeId }.singleOrNull()
                        val treeDto = treeRow?.let { tr ->
                            val images = TreeImages.selectAll().where { TreeImages.treeId eq treeId }
                                .orderBy(TreeImages.sortOrder to SortOrder.ASC).map { img ->
                                    TreeImageDto(img[TreeImages.id].toString(), img[TreeImages.imageUrl], img[TreeImages.alt], img[TreeImages.isCover], img[TreeImages.sortOrder])
                                }
                            TreeDto(
                                id = tr[Trees.id].toString(), name = tr[Trees.name],
                                description = tr[Trees.description], categoryId = tr[Trees.categoryId]?.toString(),
                                price = tr[Trees.price].toDouble(), discountPrice = tr[Trees.discountPrice]?.toDouble(),
                                stockQuantity = tr[Trees.stockQuantity], status = tr[Trees.status],
                                heightCm = tr[Trees.heightCm], potDiameterCm = tr[Trees.potDiameterCm],
                                trunkDiameterCm = tr[Trees.trunkDiameterCm], ageYears = tr[Trees.ageYears],
                                location = tr[Trees.location], careNote = tr[Trees.careNote],
                                tags = emptyList(), coverImageUrl = tr[Trees.coverImageUrl],
                                isFeatured = tr[Trees.isFeatured], isActive = tr[Trees.isActive], images = images
                            )
                        }
                        CartItemDto(
                            id = row[CartItems.id].toString(),
                            treeId = treeId.toString(),
                            quantity = row[CartItems.quantity],
                            note = row[CartItems.note],
                            tree = treeDto
                        )
                    }
                }
                call.respond(items)
            }
            post({
                summary = "Add item to cart or update quantity"
                request { body<CartItemDto>() }
                response {
                    code(HttpStatusCode.Created) { description = "Added to cart" }
                }
            }) {
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
            delete("/{id}", {
                summary = "Remove item from cart"
                request {
                    pathParameter<String>("id")
                }
                response {
                    code(HttpStatusCode.OK) { description = "Item removed" }
                }
            }) {
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
            get({
                summary = "List current user orders"
                response {
                    code(HttpStatusCode.OK) { description = "Order list" }
                }
            }) {
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
            get("/{id}", {
                summary = "Get order detail by ID"
                request {
                    pathParameter<String>("id")
                }
                response {
                    code(HttpStatusCode.OK) { description = "Order detail with items" }
                    code(HttpStatusCode.NotFound) { description = "Order not found" }
                }
            }) {
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
            post({
                summary = "Create new order"
                request { body<CreateOrderRequest>() }
                response {
                    code(HttpStatusCode.Created) { description = "Order created" }
                }
            }) {
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
                        // ponytail: if order item matches cart, clear it
                        CartItems.deleteWhere { (CartItems.userId eq userId) and (CartItems.treeId eq treeUuid) }
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
            get({
                summary = "Get current user profile"
                response {
                    code(HttpStatusCode.OK) { description = "User profile" }
                    code(HttpStatusCode.NotFound) { description = "Profile not found" }
                }
            }) {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val profile = transaction {
                    val row = Profiles.selectAll().where { Profiles.id eq userId }.singleOrNull() ?: return@transaction null
                    ProfileDto(row[Profiles.id].toString(), row[Profiles.fullName], row[Profiles.email], row[Profiles.phoneNumber], row[Profiles.avatarUrl], row[Profiles.role])
                }
                if (profile == null) call.respond(HttpStatusCode.NotFound, ApiError("Profile not found"))
                else call.respond(profile)
            }
            put({
                summary = "Update current user profile"
                request { body<UpdateProfileRequest>() }
                response {
                    code(HttpStatusCode.OK) { description = "Updated profile" }
                    code(HttpStatusCode.NotFound) { description = "Profile not found" }
                }
            }) {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val req = call.receive<UpdateProfileRequest>()
                val now = OffsetDateTime.now()
                val profile = transaction {
                    val exists = Profiles.selectAll().where { Profiles.id eq userId }.singleOrNull() != null
                    if (!exists) return@transaction null
                    Profiles.update({ Profiles.id eq userId }) {
                        if (req.fullName != null) it[fullName] = req.fullName
                        if (req.phoneNumber != null) it[phoneNumber] = req.phoneNumber
                        if (req.avatarUrl != null) it[avatarUrl] = req.avatarUrl
                        it[updatedAt] = now
                    }
                    val row = Profiles.selectAll().where { Profiles.id eq userId }.single()
                    ProfileDto(row[Profiles.id].toString(), row[Profiles.fullName], row[Profiles.email], row[Profiles.phoneNumber], row[Profiles.avatarUrl], row[Profiles.role])
                }
                if (profile == null) call.respond(HttpStatusCode.NotFound, ApiError("Profile not found"))
                else call.respond(profile)
            }

            post("/avatar", {
                summary = "Upload user avatar"
                response {
                    code(HttpStatusCode.OK) { description = "Avatar uploaded" }
                    code(HttpStatusCode.BadRequest) { description = "Invalid upload" }
                }
            }) {
                val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                val multipart = call.receiveMultipart()
                var fileName = ""
                multipart.forEachPart { part ->
                    if (part is PartData.FileItem) {
                        val ext = part.originalFileName?.substringAfterLast(".", "jpg") ?: "jpg"
                        fileName = "avatar-$userId-${System.currentTimeMillis()}.$ext"
                        // ponytail: save to static/uploads for dev MVP. In production use S3/CDN.
                        val file = java.io.File("src/main/resources/static/uploads/$fileName")
                        file.parentFile.mkdirs()
                        part.streamProvider().use { its -> file.outputStream().buffered().use { out -> its.copyTo(out) } }
                    }
                    part.dispose()
                }
                if (fileName.isNotEmpty()) {
                    val url = "/uploads/$fileName"
                    transaction {
                        Profiles.update({ Profiles.id eq userId }) { it[avatarUrl] = url }
                    }
                    call.respond(UploadResponse(url))
                } else {
                    call.respond(HttpStatusCode.BadRequest, ApiError("No file uploaded"))
                }
            }

            route("/addresses") {
                get({
                    summary = "List current user addresses"
                    response {
                        code(HttpStatusCode.OK) { description = "Address list" }
                    }
                }) {
                    val userId = UUID.fromString(call.principal<JWTPrincipal>()!!.payload.getClaim("userId").asString())
                    val addresses = transaction {
                        Addresses.selectAll().where { Addresses.userId eq userId }.map { row ->
                            AddressDto(row[Addresses.id].toString(), row[Addresses.label], row[Addresses.receiverName], row[Addresses.phoneNumber], row[Addresses.addressLine], row[Addresses.city], row[Addresses.district], row[Addresses.ward], row[Addresses.postalCode], row[Addresses.isDefault])
                        }
                    }
                    call.respond(addresses)
                }
                post({
                    summary = "Add new address"
                    request { body<AddressDto>() }
                    response {
                        code(HttpStatusCode.Created) { description = "Address created" }
                    }
                }) {
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
    get("/api/home", {
        summary = "Get home screen SDUI blocks"
        request {
            queryParameter<String>("categoryId")
        }
        response {
            code(HttpStatusCode.OK) { description = "Home screen UI blocks" }
        }
    }) {
        val categoryIdParam = call.request.queryParameters["categoryId"]
        
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
        val baseBlocks = if (blocks.isEmpty()) {
            val fallbackJson = kotlinx.serialization.json.Json
            listOf(
                UiBlockDto("seed-1", "banner_carousel", null, fallbackJson.parseToJsonElement("""{"banners":[{"tag":"SALE 20%","title":"Mang thien nhien vao nha ban","subtitle":"Giam 20% cho don hang dau tien","cta":"Mua ngay"}]}""").jsonObject, null, 0),
                UiBlockDto("seed-2", "quick_actions", null, fallbackJson.parseToJsonElement("""{"items":[{"icon":"🏠","label":"Trong nha"},{"icon":"🌳","label":"Ngoai troi"},{"icon":"🌵","label":"Sen da"},{"icon":"🪴","label":"Chau"}]}""").jsonObject, null, 1),
                UiBlockDto("seed-3", "flash_sale_strip", null, fallbackJson.parseToJsonElement("""{"title":"Flash Sale hom nay","subtitle":"Ket thuc trong","hours":2,"minutes":18,"seconds":45}""").jsonObject, null, 2),
                UiBlockDto("seed-4", "featured_hero", null, fallbackJson.parseToJsonElement("""{"label":"CAY CUA THANG","name":"Trau ba Nam My","desc":"De cham, thanh loc khong khi tot","price":"450.000₫","imageUrl":"monstera_hero.jpg"}""").jsonObject, null, 3),
                UiBlockDto("seed-5", "category_tabs", null, fallbackJson.parseToJsonElement("""{"categories":[]}""").jsonObject, null, 4),
                UiBlockDto("seed-6", "product_horizontal_list", "Ban chay tuan nay", fallbackJson.parseToJsonElement("""{"products":[]}""").jsonObject, null, 5),
                UiBlockDto("seed-7", "care_tip_card", null, fallbackJson.parseToJsonElement("""{"icon":"💧","title":"Meo tuoi cay mua kho","subtitle":"5 dau hieu cay dang khat nuoc"}""").jsonObject, null, 6),
                UiBlockDto("seed-8", "product_grid", "Tat ca san pham", fallbackJson.parseToJsonElement("""{"products":[]}""").jsonObject, null, 7)
            )
        } else blocks

        val allTrees = transaction {
            var query = Trees.selectAll().where { Trees.isActive eq true }
            if (categoryIdParam != null && categoryIdParam != "all") {
                query = query.andWhere { Trees.categoryId eq UUID.fromString(categoryIdParam) }
            }
            
            query.orderBy(Trees.createdAt to SortOrder.DESC).limit(20).map { row ->
                val price = row[Trees.price].toDouble()
                val formattedPrice = "%,.0f\u20AB".format(price).replace(",", ".")
                kotlinx.serialization.json.buildJsonObject {
                    put("id", kotlinx.serialization.json.JsonPrimitive(row[Trees.id].toString()))
                    put("name", kotlinx.serialization.json.JsonPrimitive(row[Trees.name]))
                    put("price", kotlinx.serialization.json.JsonPrimitive(formattedPrice))
                    put("sub", kotlinx.serialization.json.JsonPrimitive(row[Trees.description] ?: ""))
                    put("imageUrl", kotlinx.serialization.json.JsonPrimitive(row[Trees.coverImageUrl] ?: ""))
                }
            }
        }
        
        val categories = transaction {
            Categories.selectAll().where { Categories.isActive eq true }
                .orderBy(Categories.sortOrder to SortOrder.ASC).map { row ->
                    kotlinx.serialization.json.buildJsonObject {
                        put("id", kotlinx.serialization.json.JsonPrimitive(row[Categories.id].toString()))
                        put("name", kotlinx.serialization.json.JsonPrimitive(row[Categories.name]))
                    }
                }
        }
        
        val productsArray = kotlinx.serialization.json.JsonArray(allTrees)
        val categoriesArray = kotlinx.serialization.json.JsonArray(categories)
        
        val enrichedBlocks = baseBlocks.map { block ->
            val action = when (block.blockType) {
                "banner_carousel" -> kotlinx.serialization.json.buildJsonObject {
                    put("type", kotlinx.serialization.json.JsonPrimitive("navigate"))
                    put("path", kotlinx.serialization.json.JsonPrimitive("/search"))
                }
                "featured_hero" -> kotlinx.serialization.json.buildJsonObject {
                    val firstId = allTrees.firstOrNull()?.get("id")?.toString()?.replace("\"", "") ?: ""
                    put("type", kotlinx.serialization.json.JsonPrimitive("navigate"))
                    put("path", kotlinx.serialization.json.JsonPrimitive("/product/$firstId"))
                }
                "quick_actions" -> kotlinx.serialization.json.buildJsonObject {
                    put("type", kotlinx.serialization.json.JsonPrimitive("navigate"))
                    put("path", kotlinx.serialization.json.JsonPrimitive("/search"))
                }
                else -> null
            }
            
            when (block.blockType) {
                "product_horizontal_list", "product_grid" -> {
                    val newPayload = kotlinx.serialization.json.buildJsonObject {
                        block.payload.forEach { (k, v) -> put(k, v) }
                        put("products", productsArray)
                    }
                    block.copy(payload = newPayload, action = action)
                }
                "category_tabs" -> {
                    val newPayload = kotlinx.serialization.json.buildJsonObject {
                        put("categories", categoriesArray)
                    }
                    block.copy(payload = newPayload)
                }
                else -> {
                    block.copy(action = action)
                }
            }
        }
        call.respond(HomeSduiResponse(enrichedBlocks))
    }
}

// ponytail: admin SDUI routes, no auth for MVP. add basic auth when production
fun Route.adminSduiRoutes() {
    route("/api/admin/sdui") {
        get({
            summary = "List all SDUI blocks"
            response { code(HttpStatusCode.OK) { description = "Block list" } }
        }) {
            val screenKey = call.request.queryParameters["screenKey"] ?: "home"
            val blocks = transaction {
                UiBlocks.selectAll().where { UiBlocks.screenKey eq screenKey }
                    .orderBy(UiBlocks.sortOrder to SortOrder.ASC).map { row ->
                        mapOf(
                            "id" to row[UiBlocks.id].toString(),
                            "blockType" to row[UiBlocks.blockType],
                            "title" to row[UiBlocks.title],
                            "payload" to row[UiBlocks.payload],
                            "sortOrder" to row[UiBlocks.sortOrder],
                            "isActive" to row[UiBlocks.isActive]
                        )
                    }
            }
            call.respond(blocks)
        }
        post({
            summary = "Create new SDUI block"
            request { body<UiBlockUpsertRequest>() }
            response { code(HttpStatusCode.Created) { description = "Block created" } }
        }) {
            val req = call.receive<UiBlockUpsertRequest>()
            val id = UUID.randomUUID()
            val now = OffsetDateTime.now()
            transaction {
                UiBlocks.insert {
                    it[UiBlocks.id] = id
                    it[screenKey] = "home"
                    it[blockType] = req.blockType
                    it[title] = req.title
                    it[payload] = req.payload
                    it[sortOrder] = req.sortOrder
                    it[isActive] = req.isActive
                    it[createdAt] = now
                    it[updatedAt] = now
                }
            }
            call.respond(HttpStatusCode.Created, mapOf("id" to id.toString()))
        }
        put("/{id}", {
            summary = "Update SDUI block"
            request { body<UiBlockUpsertRequest>() }
            response {
                code(HttpStatusCode.OK) { description = "Block updated" }
                code(HttpStatusCode.NotFound) { description = "Block not found" }
            }
        }) {
            val blockId = UUID.fromString(call.parameters["id"]!!)
            val req = call.receive<UiBlockUpsertRequest>()
            val now = OffsetDateTime.now()
            val updated = transaction {
                val exists = UiBlocks.selectAll().where { UiBlocks.id eq blockId }.singleOrNull() != null
                if (!exists) return@transaction false
                UiBlocks.update({ UiBlocks.id eq blockId }) {
                    it[blockType] = req.blockType
                    it[title] = req.title
                    it[payload] = req.payload
                    it[sortOrder] = req.sortOrder
                    it[isActive] = req.isActive
                    it[updatedAt] = now
                }
                true
            }
            if (updated) call.respond(HttpStatusCode.OK, mapOf("message" to "Updated"))
            else call.respond(HttpStatusCode.NotFound, ApiError("Block not found"))
        }
        delete("/{id}", {
            summary = "Delete SDUI block"
            response {
                code(HttpStatusCode.OK) { description = "Block deleted" }
                code(HttpStatusCode.NotFound) { description = "Block not found" }
            }
        }) {
            val blockId = UUID.fromString(call.parameters["id"]!!)
            val deleted = transaction {
                val count = UiBlocks.deleteWhere { UiBlocks.id eq blockId }
                count > 0
            }
            if (deleted) call.respond(HttpStatusCode.OK, mapOf("message" to "Deleted"))
            else call.respond(HttpStatusCode.NotFound, ApiError("Block not found"))
        }
    }
}

fun Route.otpRoutes() {
    route("/api/auth") {
        post("/send-otp", {
            summary = "Send OTP to email"
            request { body<SendOtpRequest>() }
            response {
                code(HttpStatusCode.OK) { description = "OTP sent" }
            }
        }) {
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
        post("/verify-otp", {
            summary = "Verify OTP code"
            request { body<VerifyOtpRequest>() }
            response {
                code(HttpStatusCode.OK) { description = "OTP verified" }
                code(HttpStatusCode.BadRequest) { description = "Invalid or expired OTP" }
            }
        }) {
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
        post("/forgot-password", {
            summary = "Request password reset OTP"
            request { body<ForgotPasswordRequest>() }
            response {
                code(HttpStatusCode.OK) { description = "OTP sent for password reset" }
                code(HttpStatusCode.NotFound) { description = "Email not found" }
            }
        }) {
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
        post("/reset-password", {
            summary = "Reset password with OTP"
            request { body<ResetPasswordRequest>() }
            response {
                code(HttpStatusCode.OK) { description = "Password reset successful" }
                code(HttpStatusCode.BadRequest) { description = "Invalid or expired OTP" }
            }
        }) {
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