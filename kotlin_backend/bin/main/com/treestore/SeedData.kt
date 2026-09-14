package com.treestore

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import java.time.OffsetDateTime
import java.util.*

// ponytail: hardcoded seed data for dev only. Replace with proper migration/seeder tool when production
object SeedData {
    fun seedIfEmpty() {
        transaction {
            if (Categories.selectAll().count() > 0) return@transaction

            val now = OffsetDateTime.now()
            val catIds = List(4) { UUID.randomUUID() }

            Categories.batchInsert(
                listOf(
                    listOf("Cây trong nhà", "cay-trong-nha", "Thanh lọc không khí, trang trí nội thất", 0),
                    listOf("Cây ngoài trời", "cay-ngoai-troi", "Chịu nắng tốt, phù hợp sân vườn", 1),
                    listOf("Sen đá", "sen-da", "Ít nước, dễ chăm, để bàn làm việc", 2),
                    listOf("Bonsai", "bonsai", "Nghệ thuật thu nhỏ thiên nhiên", 3)
                )
            ) { row ->
                this[Categories.id] = catIds[row[3] as Int]
                this[Categories.name] = row[0] as String
                this[Categories.slug] = row[1] as String
                this[Categories.description] = row[2] as String?
                this[Categories.sortOrder] = row[3] as Int
                this[Categories.isActive] = true
                this[Categories.createdAt] = now
                this[Categories.updatedAt] = now
            }

            val trees = listOf(
                Triple("Monstera Deliciosa", "Lá xẻ đặc trưng, thanh lọc không khí tốt. Phù hợp phòng khách.", 0),
                Triple("Cây Lưỡi Hổ", "Chịu bóng tốt, hút formaldehyde. Gần như không cần chăm.", 0),
                Triple("Cây Bàng Singapore", "Lá to xanh mướt, chịu nắng bán phần. Trang trí ban công.", 1),
                Triple("Cây Hoa Giấy", "Nhiều màu sắc, chịu nắng trực tiếp. Leo giàn hoặc trồng chậu.", 1),
                Triple("Sen Đá Echeveria", "Rosette đẹp, nhiều màu. Tưới ít, đặt nơi sáng.", 2),
                Triple("Sen Đá Chuỗi Ngọc", "Thân rủ mềm mại, phù hợp chậu treo.", 2),
                Triple("Bonsai Tùng La Hán", "Dáng cổ thụ, lá kim xanh quanh năm. Biểu tượng trường thọ.", 3),
                Triple("Bonsai Linh Sam", "Hoa tím nhỏ xinh, thân uốn dẻo. Dễ tạo dáng cho người mới.", 3),
                Triple("Cây Kim Tiền", "Lá xanh bóng, tượng trưng cho tài lộc. Thích hợp để bàn.", 0),
                Triple("Cây Lan Ý", "Hoa trắng thanh thoát, lọc bụi mịn và sóng điện từ tốt.", 0),
                Triple("Trầu Bà Thanh Xuân", "Lá to xẻ sâu, tạo không gian xanh mát ấn tượng.", 0),
                Triple("Cây Đuôi Công", "Họa tiết lá độc đáo như lông công. Sống tốt trong bóng râm.", 0),
                Triple("Cây Tùng Bồng Lai", "Lá nhỏ như mây, mang lại may mắn và sức khỏe.", 1),
                Triple("Xương Rồng Tai Thỏ", "Dáng ngộ nghĩnh, rất ít nước, chịu nắng gắt cực tốt.", 1),
                Triple("Sen Đá Móng Rồng", "Lá cứng cáp, vằn trắng nổi bật. Siêu bền, ít cần chăm.", 2),
                Triple("Bonsai Hoa Mai", "Vẻ đẹp ngày Tết, cánh vàng rực rỡ, dáng thế nghệ thuật.", 3),
                Triple("Bonsai Hoa Đào", "Sắc hồng mùa xuân, gốc xù xì cổ kính, hoa nở rộ.", 3),
                Triple("Cây Ngũ Gia Bì", "Lá kép hình chân chim, đuổi muỗi và lọc không khí.", 0),
                Triple("Cây Thiết Mộc Lan", "Thân cột vững chãi, lá xanh sọc vàng, mang lại vượng khí.", 0),
                Triple("Cây Vạn Niên Thanh", "Sức sống mãnh liệt, lá to xanh trắng, phong thủy tốt.", 0)
            )

            val prices = listOf(
                350000, 180000, 450000, 220000, 85000, 120000, 1500000, 680000,
                250000, 150000, 320000, 280000, 190000, 95000, 75000, 2500000,
                2200000, 160000, 480000, 140000
            )

            val treeIds = trees.map { UUID.randomUUID() }
            Trees.batchInsert(trees.mapIndexed { i, t -> Triple(t.first, t.second, t.third) to i }) { entry ->
                val tree = entry.first
                val idx = entry.second
                this[Trees.id] = treeIds[idx]
                this[Trees.name] = tree.first
                this[Trees.description] = tree.second
                this[Trees.categoryId] = catIds[tree.third]
                this[Trees.price] = java.math.BigDecimal(prices[idx])
                this[Trees.stockQuantity] = 10
                this[Trees.status] = "available"
                // Reuse the 15 images we have
                val imgIdx = (idx % 15) + 1
                this[Trees.coverImageUrl] = "/images/cay$imgIdx.jpg"
                this[Trees.isFeatured] = idx < 4 || idx >= 15
                this[Trees.isActive] = true
                this[Trees.tags] = "[]"
                this[Trees.extraSpecs] = "{}"
                this[Trees.createdAt] = now
                this[Trees.updatedAt] = now
            }

            // ponytail: seed 1 cover image per tree. Add more variants when admin CMS available
            TreeImages.batchInsert(treeIds.mapIndexed { i, tid -> Pair(tid, i) }) { entry ->
                val tid = entry.first
                val idx = entry.second
                val imgIdx = (idx % 15) + 1
                this[TreeImages.id] = UUID.randomUUID()
                this[TreeImages.treeId] = tid
                this[TreeImages.imageUrl] = "/images/cay$imgIdx.jpg"
                this[TreeImages.alt] = trees[idx].first
                this[TreeImages.isCover] = true
                this[TreeImages.sortOrder] = 0
                this[TreeImages.createdAt] = now
            }

            // ponytail: SDUI blocks match fallback in homeRoutes. Remove after real CMS
            val blocks = listOf(
                Pair("banner_carousel", """{"banners":[{"tag":"SALE 20%","title":"Mang thien nhien vao nha ban","subtitle":"Giam 20% cho don hang dau tien","cta":"Mua ngay"}]}"""),
                Pair("quick_actions", """{"items":[{"icon":"🏠","label":"Trong nha"},{"icon":"🌳","label":"Ngoai troi"},{"icon":"🌵","label":"Sen da"},{"icon":"🪴","label":"Chau"}]}"""),
                Pair("flash_sale_strip", """{"title":"Flash Sale hom nay","subtitle":"Ket thuc trong","hours":2,"minutes":18,"seconds":45}"""),
                Pair("featured_hero", """{"label":"CAY CUA THANG","name":"Trau ba Nam My","desc":"De cham, thanh loc khong khi tot","price":"450.000₫","imageUrl":"assets/images/cay-1.jpg"}"""),
                Pair("category_tabs", """{"categories":["Tat ca","Cay la","Sen da","Bonsai"]}"""),
                Pair("product_horizontal_list", """{"products":[]}"""),
                Pair("care_tip_card", """{"icon":"💧","title":"Meo tuoi cay mua kho","subtitle":"5 dau hieu cay dang khat nuoc"}"""),
                Pair("product_grid", """{"products":[]}""")
            )

            UiBlocks.batchInsert(blocks.mapIndexed { i, b -> Pair(i, b) }) { entry ->
                val idx = entry.first
                val block = entry.second
                this[UiBlocks.id] = UUID.randomUUID()
                this[UiBlocks.screenKey] = "home"
                this[UiBlocks.blockType] = block.first
                this[UiBlocks.payload] = block.second
                this[UiBlocks.sortOrder] = idx
                this[UiBlocks.isActive] = true
                this[UiBlocks.createdAt] = now
                this[UiBlocks.updatedAt] = now
            }

            println("[DEBUG] Seeded ${catIds.size} categories, ${trees.size} trees, ${blocks.size} ui_blocks")
        }
    }

    // ponytail: one-time migration for dev DBs seeded with old asset paths.
    // Runs on every startup; idempotent (only touches rows with legacy data).
    fun backfillImages() {
        transaction {
            val now = OffsetDateTime.now()
            // 1. Fix trees.cover_image_url: "assets/images/cay-N.jpg" -> "/images/cayN.jpg"
            val legacyTrees = Trees.selectAll().where {
                Trees.coverImageUrl like "assets/images/cay-%"
            }.toList()
            legacyTrees.forEach { row ->
                val old = row[Trees.coverImageUrl] ?: return@forEach
                // Extract index from "assets/images/cay-N.jpg"
                val n = Regex("cay-(\\d+)").find(old)?.groupValues?.get(1) ?: return@forEach
                Trees.update({ Trees.id eq row[Trees.id] }) {
                    it[coverImageUrl] = "/images/cay$n.jpg"
                    it[updatedAt] = now
                }
            }
            // 2. Insert tree_images rows for trees that have none yet
            val treesWithoutImages = Trees.selectAll().where { Trees.isActive eq true }.filter { t ->
                TreeImages.selectAll().where { TreeImages.treeId eq t[Trees.id] }.empty()
            }
            treesWithoutImages.forEach { t ->
                val cover = t[Trees.coverImageUrl]
                if (cover != null && cover.startsWith("/images/")) {
                    TreeImages.insert {
                        it[id] = UUID.randomUUID()
                        it[treeId] = t[Trees.id]
                        it[imageUrl] = cover
                        it[alt] = t[Trees.name]
                        it[isCover] = true
                        it[sortOrder] = 0
                        it[createdAt] = now
                    }
                }
            }
            if (legacyTrees.isNotEmpty() || treesWithoutImages.isNotEmpty()) {
                println("[DEBUG] Backfilled ${legacyTrees.size} tree cover paths, ${treesWithoutImages.size} tree_images rows")
            }
        }
    }
}