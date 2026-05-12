import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '乡镇资讯',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            key: const ValueKey('publish_news_button'),
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: '发布资讯',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('跳转至发布资讯页面')));
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('news_card_$index'),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8C00), Color(0xFFFFB74D)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '站点管理员',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '清河村驿站',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isFirst
                                ? const Color(0xFFFFF3E0)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isFirst ? '紧急通知' : '驿站动态',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isFirst
                                  ? const Color(0xFFFF8C00)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      index == 0
                          ? '⚠️ 明日暴雨预警，部分快递可能会延迟派送，请大家谅解！'
                          : '驿站新增积分兑换商品：金龙鱼洗衣液，大家快来兑换吧~',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _ActionChip(
                          icon: Icons.thumb_up_alt_outlined,
                          count: '${10 + index * 5}',
                        ),
                        const SizedBox(width: 20),
                        _ActionChip(
                          icon: Icons.chat_bubble_outline_rounded,
                          count: '${2 + index}',
                        ),
                        const Spacer(),
                        Text(
                          '2小时前',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.count});

  final IconData icon;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
      ],
    );
  }
}
