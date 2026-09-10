$f = "D:\AppData\Code\Project\Android\tree_store\kotlin_backend\src\main\kotlin\com\treestore\Routes.kt"
$c = @"
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
            call.respond(HttpStatusCode.Created, AuthResponse(token, id.toString(), "customer"))
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
            call.respond(AuthResponse(token, userId, role))
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
                if (keyword != null) query = query.andWhere { Trees.name like "%`${keyword}%" }
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
"@
[System.IO.File]::WriteAllText($f, $c, [System.Text.UTF8Encoding]::new($false))
Write-Host "OK"
</parameter>
<parameter name="isBlocking">false