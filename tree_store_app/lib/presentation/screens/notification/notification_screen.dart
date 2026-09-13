import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockNotifications = [
      {
        'id': '1',
        'title': 'Khuyến mãi cực hot! 🔥',
        'content': 'Giảm ngay 20% cho đơn hàng đầu tiên của bạn. Nhập mã VERDANT20 ngay.',
        'time': '5 phút trước',
        'type': 'promo',
        'isRead': false,
      },
      {
        'id': '2',
        'title': 'Đơn hàng đang đến 🚚',
        'content': 'Đơn hàng #VD-2026-08402 đang trên đường giao tới bạn. Vui lòng để ý điện thoại.',
        'time': '2 giờ trước',
        'type': 'order',
        'isRead': true,
      },
      {
        'id': '3',
        'title': 'Mẹo chăm sóc cây 🌿',
        'content': 'Mùa hanh khô đã đến, đừng quên xịt phun sương cho cây Trầu bà nhé.',
        'time': '1 ngày trước',
        'type': 'tip',
        'isRead': true,
      },
      {
        'id': '4',
        'title': 'Chào mừng bạn đến với Verdant 🌱',
        'content': 'Cảm ơn bạn đã tham gia hành trình phủ xanh không gian sống cùng chúng tôi.',
        'time': '3 ngày trước',
        'type': 'system',
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Đã đọc tất cả', style: TextStyle(color: AppColors.green700, fontSize: 13)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final n = mockNotifications[index];
          return _buildNotificationCard(n);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n) {
    IconData icon;
    Color iconColor;
    switch (n['type']) {
      case 'promo':
        icon = Icons.local_offer_outlined;
        iconColor = AppColors.terra;
        break;
      case 'order':
        icon = Icons.local_shipping_outlined;
        iconColor = Colors.blue;
        break;
      case 'tip':
        icon = Icons.eco_outlined;
        iconColor = AppColors.green700;
        break;
      default:
        icon = Icons.notifications_none;
        iconColor = AppColors.muted;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: n['isRead'] ? AppColors.paper : AppColors.green50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: n['isRead'] ? AppColors.line2 : AppColors.green500.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        n['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: n['isRead'] ? FontWeight.w600 : FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (!n['isRead'])
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.terra, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n['content'],
                  style: const TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  n['time'],
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}