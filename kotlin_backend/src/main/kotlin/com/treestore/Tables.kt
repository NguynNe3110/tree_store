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

object Payments : Table("payments") {
    val id = uuid("id")
    val orderId = uuid("order_id")
    val provider = text("provider")
    val orderCode = long("order_code").uniqueIndex()
    val providerPaymentId = text("provider_payment_id").nullable()
    val transactionNo = text("transaction_no").nullable()
    val amount = long("amount")
    val status = text("status").default("pending")
    val checkoutUrl = text("checkout_url").nullable()
    val rawWebhook = text("raw_webhook").nullable()
    val paidAt = timestampWithTimeZone("paid_at").nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
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

object OtpCodes : Table("otp_codes") {
    val id = uuid("id")
    val email = text("email")
    val code = text("code")
    val purpose = text("purpose")
    val expiresAt = timestampWithTimeZone("expires_at")
    val isUsed = bool("is_used").default(false)
    val createdAt = timestampWithTimeZone("created_at")
    override val primaryKey = PrimaryKey(id)
}

object UiBlocks : Table("ui_blocks") {
    val id = uuid("id")
    val screenKey = text("screen_key")
    val blockType = text("block_type")
    val title = text("title").nullable()
    val payload = text("payload").default("{}")
    val sortOrder = integer("sort_order").default(0)
    val isActive = bool("is_active").default(true)
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    override val primaryKey = PrimaryKey(id)
}