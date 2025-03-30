import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isPosting = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_postController.text.isEmpty || _currentUser == null) return;

    setState(() => _isPosting = true);

    try {
      await _firestore.collection('community_posts').add({
        'content': _postController.text,
        'authorId': _currentUser!.uid,
        'authorName': _currentUser!.displayName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'category': 'General',
      });

      _postController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    } finally {
      setState(() => _isPosting = false);
    }
  }

  Future<void> _likePost(String postId, int currentLikes) async {
    try {
      await _firestore.collection('community_posts').doc(postId).update({
        'likes': currentLikes + 1,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like post: $e')),
      );
    }
  }

  void _showPostDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Create New Post',
          style: TextStyle(color: textColor),
        ),
        content: TextField(
          controller: _postController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'What would you like to share?',
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            border: OutlineInputBorder(),
          ),
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _createPost();
              if (mounted) Navigator.pop(context);
            },
            child: _isPosting
                ? const CircularProgressIndicator()
                : const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final cardColor = themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;
    final dividerColor = themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPostDialog(context),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context,
                    'Announcements',
                    'Important updates and news',
                    '24 topics',
                    Icons.announcement,
                    cardColor,
                    dividerColor,
                    textColor,
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryCard(
                    context,
                    'General Discussion',
                    'Chat about anything art toy related',
                    '156 topics',
                    Icons.chat,
                    cardColor,
                    dividerColor,
                    textColor,
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryCard(
                    context,
                    'Artist Corner',
                    'Share your creations',
                    '89 topics',
                    Icons.palette,
                    cardColor,
                    dividerColor,
                    textColor,
                  ),

                  // Recent Posts Section
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Discussions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('community_posts')
                        .orderBy('timestamp', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: textColor));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No discussions yet',
                            style: TextStyle(color: textColor.withOpacity(0.7)),
                          ),
                        );
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildPostItem(
                            context,
                            data['content'] ?? '',
                            data['authorName'] ?? 'Anonymous',
                            (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                            data['likes'] ?? 0,
                            data['comments'] ?? 0,
                            doc.id,
                            dividerColor,
                            textColor,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, themeProvider),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String subtitle,
    String trailingText,
    IconData icon,
    Color cardColor,
    Color dividerColor,
    Color textColor,
  ) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: dividerColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: textColor.withOpacity(0.7)),
        ),
        trailing: Text(
          trailingText,
          style: TextStyle(color: textColor),
        ),
        onTap: () {
          // Navigate to category page
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) => CategoryPage(category: title),
          // ));
        },
      ),
    );
  }

  Widget _buildPostItem(
    BuildContext context,
    String content,
    String author,
    DateTime timestamp,
    int likes,
    int comments,
    String postId,
    Color dividerColor,
    Color textColor,
  ) {
    final timeAgo = _formatTimeAgo(timestamp);

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            content,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Posted by $author • $timeAgo',
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border, size: 20, color: textColor),
                    onPressed: () => _likePost(postId, likes),
                  ),
                  Text(
                    likes.toString(),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.comment, size: 20, color: textColor),
                  const SizedBox(width: 4),
                  Text(
                    comments.toString(),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            // Navigate to post detail page
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (context) => PostDetailPage(postId: postId),
            // ));
          },
        ),
        Divider(color: dividerColor),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, ThemeProvider themeProvider) {
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final selectedColor = Colors.blue;
    final unselectedColor = themeProvider.isDarkMode ? Colors.grey[500]! : Colors.grey;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(
            context, '/home', (route) => false);
        } else if (index == 1) {
          Navigator.pushNamed(context, '/categories');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/watchlist');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Watchlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
}