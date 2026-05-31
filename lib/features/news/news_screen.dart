import 'package:flutter/material.dart';
import '../../core/models/business_models.dart';
import '../../services/app_data_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _appDataService = AppDataService();
  List<NewsPostVO> _posts = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    final result = await _appDataService.getNewsPosts();
    if (!mounted) {
      return;
    }
    setState(() {
      _posts = result.data ?? const [];
      _isLoading = false;
    });
  }

  void _showPublishSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '发布乡镇动态',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('news_content_field'),
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '分享今天的驿站动态、村务通知或互助信息...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const ValueKey('publish_news_confirm_button'),
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty) {
                    return;
                  }
                  final result = await _appDataService.publishNews(text);
                  final post = result.data;
                  if (!context.mounted) {
                    return;
                  }
                  if (!result.isSuccess || post == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result.message)));
                    return;
                  }
                  setState(() {
                    _posts.insert(0, post);
                  });
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('发布内容'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '乡镇资讯',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('publish_news_fab'),
        onPressed: _showPublishSheet,
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: _posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _NewsCard(
                  post: post,
                  index: index,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailScreen(post: post),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.post,
    required this.index,
    required this.onTap,
  });

  final NewsPostVO post;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NewsAuthorRow(post: post),
              const SizedBox(height: 14),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
                    count: '${post.likes}',
                  ),
                  const SizedBox(width: 20),
                  _ActionChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    count: '${post.comments.length}',
                  ),
                  const Spacer(),
                  Text(
                    post.publishedAtText,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsAuthorRow extends StatelessWidget {
  const _NewsAuthorRow({required this.post});

  final NewsPostVO post;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: const Icon(Icons.store_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                post.stationName,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: post.isUrgent ? const Color(0xFFFFF3E0) : Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            post.tag,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: post.isUrgent ? const Color(0xFFFF8C00) : Colors.grey[600],
            ),
          ),
        ),
      ],
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

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({super.key, required this.post});

  final NewsPostVO post;

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late int _likes;
  late final List<String> _comments;
  bool _liked = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likes;
    _comments = [...widget.post.comments];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() => _comments.add(text));
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('资讯详情')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NewsAuthorRow(post: widget.post),
                      const SizedBox(height: 18),
                      Text(
                        widget.post.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.post.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          FilledButton.icon(
                            key: const ValueKey('news_like_button'),
                            onPressed: _toggleLike,
                            style: FilledButton.styleFrom(
                              backgroundColor: _liked
                                  ? const Color(0xFFFF8C00)
                                  : Colors.grey[100],
                              foregroundColor: _liked
                                  ? Colors.white
                                  : const Color(0xFF666666),
                              minimumSize: const Size(120, 42),
                            ),
                            icon: Icon(
                              _liked
                                  ? Icons.thumb_up_alt_rounded
                                  : Icons.thumb_up_alt_outlined,
                            ),
                            label: Text('点赞 $_likes'),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_comments.length} 条评论',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '评论',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ..._comments.map(
                  (comment) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(comment)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              10 + MediaQuery.of(context).padding.bottom,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('news_comment_field'),
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: '写下你的评论...'),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  key: const ValueKey('send_comment_button'),
                  onPressed: _sendComment,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(72, 48),
                  ),
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
