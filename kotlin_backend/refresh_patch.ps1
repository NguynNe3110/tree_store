$base = "D:\AppData\Code\Project\Android\tree_store\kotlin_backend\src\main"
$enc = [System.Text.UTF8Encoding]::new($false)

# 1. Tables.kt - append RefreshTokens table
$tablesContent = @'
package com.treestore

import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

object Profiles : Table("profiles") {
    val id = uuid("id")
    val fullName = text("full_name")
    val email = text("email").nullable().uniqueIndex()
    val phoneNumber = text("phone_number").nullable().uniqueIndex()
    val avatarUrl = text("avatar_url").nullable()
    val role = text("role").default("customer")
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    override val primaryKey = PrimaryKey(id)
}

object Categories : Table("categories") {
    val id = uuid("id")
    val name = text("name").uniqueIndex()
    val slug = text("slug").uniqueIndex()
    val description = text("description").nullable()
    val imageUrl = text("image_url").nullable()
    val sortOrder = integer("sort_order").default(0)
    val isActive = bool("is_active").default(true)
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    override val primaryKey = PrimaryKey(id)
}

object Trees : Table("trees") {
    val id = uuid("id")
    val name = text("name")
    val description = text("description").nullable()
    val categoryId = uuid("category_id").nullable()
    val price = decimal("price", 14, 2)
    val discountPrice = decimal("discount_price", 14, 2).nullable()
    val stockQuantity = integer("stock_quantity").default(1)
    val status = text("status").default("draft")
    val heightCm = integer("height_cm").nullable()
    val potDiameterCm = integer("pot_diameter_cm").nullable()
    val trunkDiameterCm = integer("trunk_diameter_cm").nullable()
    val ageYears = integer("age_years").nullable()
    val location = text("location").nullable()
    val careNote = text("care_note").nullable()
    val tags = text("tags").default("[]")
    val extraSpecs = text("extra_specs").default("{}")
    val coverImageUrl = text("cover_image_url").nullable()
    val isFeatured = bool("is_featured").default(false)
    val isActive = bool("is_active").default(true)
    val createdBy = uuid("created_by").nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    override val primaryKey = PrimaryKey(id)
}

object TreeImages : Table("tree_images") {
    val id = uuid("id")
    val treeId = uuid("tree_id")
    val imageUrl = text("image_url")
    val alt = text("alt").nullable()
    val isCover = bool("is_cover").default(false)
    val sortOrder = integer("sort_order").default(0)
    val createdAt = timestampWithTimeZone("created_at")
    override val primaryKey = PrimaryKey(id)
}

object CartItems : Table("cart_items") {
    val id = uuid("id")
    val userId = uuid("user_id")
    val treeId = uuid("tree_id")
    val quantity = integer("quantity").default(1)
    val note = text("note").nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    override val primaryKey = PrimaryKey(id)
}

object Addresses : Table("addresses") {
    val id = uuid("id")
    val userId = uuid("user_id")
    val label = text("label").nullable()
    val receiverName = text("receiver_name")
    val phoneNumber = text("phone_number")
    val addressLine = text("address_line")
    val city = text("city")
    val district = text("district")
    val ward = text("ward").nullable()
    val postalCode = text("postal_code").nullable()
    val isDefault = bool("is_default").default(false)
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    override val primaryKey = PrimaryKey(id)
}

object Orders : Table("orders") {
    val id = uuid("id")
    val userId = uuid("user_id").nullable()
    val addressId = uuid("address_id").nullable()
    val status = text("status").default("pending")
    val paymentMethod = text("payment_method").default("cod")
    val paymentStatus = text("payment_status").default("unpaid")
    val subtotalPrice = decimal("subtotal_price", 14, 2).default(java.math.BigDecimal.ZERO)
    val shippingFee = decimal("shipping_fee", 14, 2).default(java.math.BigDecimal.ZERO)
    val discountAmount = decimal("discount_amount", 14, 2).default(java.math.BigDecimal.ZERO)
    val totalPrice = decimal("total_price", 14, 2).default(java.math.BigDecimal.ZERO)
    val receiverName = text("receiver_name")
    val phoneNumber = text("phone_number")
    val addressLine = text("address_line")
    val city = text("city")
    val district = text("district")
    val ward = text("ward").nullable()
    val postalCode = text("postal_code").nullable()
    val note = text("note").nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    override val primaryKey = PrimaryKey(id)
}

object OrderItems : Table("order_items") {
    val id = uuid("id")
    val orderId = uuid("order_id")
    val treeId = uuid("tree_id").nullable()
    val treeNameSnapshot = text("tree_name_snapshot")
    val unitPriceSnapshot = decimal("unit_price_snapshot", 14, 2)
    val quantity = integer("quantity").default(1)
    val imageUrlSnapshot = text("image_url_snapshot").nullable()
    val specsSnapshot = text("specs_snapshot").default("{}")
    val lineTotal = decimal("line_total", 14, 2).default(java.math.BigDecimal.ZERO)
    val createdAt = timestampWithTimeZone("created_at")
    override val primaryKey = PrimaryKey(id)
}

object RefreshTokens : Table("refresh_tokens") {
    val id = uuid("id")
    val userId = uuid("user_id")
    val tokenHash = text("token_hash").uniqueIndex()
    val expiresAt = timestampWithTimeZone("expires_at")
    val createdAt = timestampWithTimeZone("created_at")
    override val primaryKey = PrimaryKey(id)
}
'@
[System.IO.File]::WriteAllText("$base\kotlin\com\treestore\Tables.kt", $tablesContent, $enc)
Write-Host "Tables.kt done"

# 2. Dtos.kt - update AuthResponse + add RefreshRequest
$dtosContent = @'
package com.treestore

import kotlinx.serialization.Serializable

@Serializable
data class LoginRequest(val email: String, val password: String)

@Serializable
data class RegisterRequest(val fullName: String, val email: String, val phoneNumber: String? = null, val password: String)

@Serializable
data class AuthResponse(val token: String, val refreshToken: String, val userId: String, val role: String)

@Serializable
data class RefreshRequest(val refreshToken: String)

@Serializable
data class CategoryDto(
    val id: String,
    val name: String,
    val slug: String,
    val description: String? = null,
    val imageUrl: String? = null,
    val sortOrder: Int = 0,
    val isActive: Boolean = true
)

@Serializable
data class TreeImageDto(
    val id: String? = null,
    val imageUrl: String,
    val alt: String? = null,
    val isCover: Boolean = false,
    val sortOrder: Int = 0
)

@Serializable
data class TreeDto(
    val id: String,
    val name: String,
    val description: String? = null,
    val categoryId: String? = null,
    val price: Double,
    val discountPrice: Double? = null,
    val stockQuantity: Int = 1,
    val status: String = "available",
    val heightCm: Int? = null,
    val potDiameterCm: Int? = null,
    val trunkDiameterCm: Int? = null,
    val ageYears: Int? = null,
    val location: String? = null,
    val careNote: String? = null,
    val tags: List<String> = emptyList(),
    val coverImageUrl: String? = null,
    val isFeatured: Boolean = false,
    val isActive: Boolean = true,
    val images: List<TreeImageDto> = emptyList()
)

@Serializable
data class TreeListResponse(val data: List<TreeDto>, val page: Int, val limit: Int, val total: Long)

@Serializable
data class CartItemDto(
    val id: String? = null,
    val treeId: String,
    val quantity: Int = 1,
    val note: String? = null,
    val tree: TreeDto? = null
)

@Serializable
data class OrderItemInput(val treeId: String, val quantity: Int)

@Serializable
data class CreateOrderRequest(
    val customerName: String,
    val phoneNumber: String,
    val addressLine: String,
    val city: String,
    val district: String,
    val ward: String? = null,
    val postalCode: String? = null,
    val note: String? = null,
    val items: List<OrderItemInput>,
    val paymentMethod: String = "cod",
    val shippingFee: Double = 0.0,
    val discountAmount: Double = 0.0
)

@Serializable
data class OrderItemDto(
    val id: String,
    val treeId: String? = null,
    val treeNameSnapshot: String,
    val unitPriceSnapshot: Double,
    val quantity: Int,
    val imageUrlSnapshot: String? = null,
    val lineTotal: Double
)

@Serializable
data class OrderDto(
    val id: String,
    val userId: String? = null,
    val status: String,
    val paymentMethod: String,
    val paymentStatus: String,
    val subtotalPrice: Double,
    val shippingFee: Double,
    val discountAmount: Double,
    val totalPrice: Double,
    val receiverName: String,
    val phoneNumber: String,
    val addressLine: String,
    val city: String,
    val district: String,
    val ward: String? = null,
    val note: String? = null,
    val items: List<OrderItemDto> = emptyList()
)

@Serializable
data class ProfileDto(
    val id: String,
    val fullName: String,
    val email: String? = null,
    val phoneNumber: String? = null,
    val avatarUrl: String? = null,
    val role: String
)

@Serializable
data class AddressDto(
    val id: String? = null,
    val label: String? = null,
    val receiverName: String,
    val phoneNumber: String,
    val addressLine: String,
    val city: String,
    val district: String,
    val ward: String? = null,
    val postalCode: String? = null,
    val isDefault: Boolean = false
)

@Serializable
data class ApiError(val message: String)
'@
[System.IO.File]::WriteAllText("$base\kotlin\com\treestore\Dtos.kt", $dtosContent, $enc)
Write-Host "Dtos.kt done"

# 3. application.conf - add TTL config
$confContent = @'
ktor {
    deployment {
        port = 8080
    }
    application {
        modules = [ com.treestore.ApplicationKt.module ]
    }
}

db {
    jdbcUrl = "jdbc:postgresql://localhost:5432/tree_store"
    driverClassName = "org.postgresql.Driver"
    user = "postgres"
    password = "postgres"
    maximumPoolSize = 10
}

jwt {
    secret = "tree-store-secret-key-change-in-production-min-256-bits-long!!"
    issuer = "tree-store-backend"
    audience = "tree-store-app"
    realm = "tree-store"
    accessTokenTtlMinutes = 15
    refreshTokenTtlDays = 7
}
'@
[System.IO.File]::WriteAllText("$base\resources\application.conf", $confContent, $enc)
Write-Host "application.conf done"

Write-Host "Phase 1 complete"
</parameter>
<parameter name="isBlocking">false