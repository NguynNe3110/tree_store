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
data class SendOtpRequest(val email: String, val purpose: String)

@Serializable
data class VerifyOtpRequest(val email: String, val code: String, val purpose: String)

@Serializable
data class ForgotPasswordRequest(val email: String)

@Serializable
data class ResetPasswordRequest(val email: String, val code: String, val newPassword: String)

@Serializable
data class OtpResponse(val message: String, val expiresInSeconds: Int = 300)

@Serializable
data class UiBlockDto(
    val id: String,
    val blockType: String,
    val title: String? = null,
    val payload: kotlinx.serialization.json.JsonObject = kotlinx.serialization.json.JsonObject(emptyMap()),
    val sortOrder: Int = 0
)

@Serializable
data class HomeSduiResponse(val blocks: List<UiBlockDto>)

@Serializable
data class ApiError(val message: String)