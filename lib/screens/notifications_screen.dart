import 'package:flutter/material.dart';
import 'package:hanapp/models/notification.dart'; // Ensure correct import path
import 'package:hanapp/utils/notification_service.dart'; // Ensure correct import path
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanapp/utils/auth_service.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:hanapp/screens/unified_chat_screen.dart'; // Ensure this is imported for chat navigation
import 'package:hanapp/screens/lister/listing_details_screen.dart'; // Ensure this is imported if you still use it elsewhere
import 'package:hanapp/screens/lister/application_overview_screen.dart'; // NEW: Import the new screen
import 'package:hanapp/screens/user_profile_screen.dart'; // Import UserProfileScreen

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndFetchNotifications();
  }

  Future<void> _loadCurrentUserAndFetchNotifications() async {
    final user = await AuthService.getUser();
    if (user == null || user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in to view notifications.')),
      );
      // Removed pop, as it might pop the entire app if this is the first screen
      return;
    }
    _currentUserId = user.id;
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (_currentUserId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final response = await _notificationService.getNotifications(_currentUserId!);
    setState(() {
      _isLoading = false;
      if (response['success']) {
        _notifications = response['notifications'];
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: ${response['message']}')),
        );
      }
    });
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    // Optimistically update UI
    setState(() {
      final index = _notifications.indexOf(notification);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          relatedEntityId: notification.relatedEntityId,
          isRead: true, // Mark as read in UI
          timestamp: notification.timestamp,
          senderName: notification.senderName,
          senderProfilePictureUrl: notification.senderProfilePictureUrl,
          senderId: notification.senderId, // Pass senderId here
        );
      }
    });

    try {
      await _notificationService.markNotificationAsRead(notification.id.toString());
    } catch (e) {
      print('Error marking notification as read: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark notification as read: $e')),
      );
      // Revert UI if API call fails
      setState(() {
        final index = _notifications.indexOf(notification);
        if (index != -1) {
          _notifications[index] = notification; // Revert to original (unread) state
        }
      });
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    _markAsRead(notification); // Mark as read when tapped

    switch (notification.type) {
      case NotificationType.application:
        if (notification.relatedEntityId != null) {
          // NEW: Navigate to the dedicated ApplicationOverviewScreen
          // For 'application' type, relatedEntityId should be the application_id
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ApplicationOverviewScreen(applicationId: notification.relatedEntityId!),
          ));
        }
        break;
      case NotificationType.message:
      case NotificationType.reply:
        if (notification.senderId != null && notification.senderName != null && notification.relatedEntityId != null) {
          // Assuming relatedEntityId for message/reply notifications is the listingId
          Navigator.of(context).pushNamed(
            '/unified_chat_screen',
            arguments: {
              'recipientId': notification.senderId,
              'recipientName': notification.senderName,
              'listingId': notification.relatedEntityId, // This should be the listing ID associated with the conversation
              // 'isLister' needs to be determined based on currentUser's role and listing's listerId
              // This might require fetching listing details or passing more info in notification payload
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat details not available for this notification.')),
          );
        }
        break;
      case NotificationType.job_confirmed:
      case NotificationType.job_marked_done_by_doer:
      case NotificationType.job_completed:
        if (notification.relatedEntityId != null) {
          // These notifications are related to a job/listing status change
          // For these, relatedEntityId should be the listing_id
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ApplicationOverviewScreen(applicationId: notification.relatedEntityId!), // Assuming relatedEntityId is application_id here
          ));
        }
        break;
      case NotificationType.review_received:
        if (notification.relatedEntityId != null) {
          // Assuming relatedEntityId for review_received is the ID of the user who was reviewed
          Navigator.of(context).pushNamed('/user_profile', arguments: {'userId': notification.relatedEntityId});
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification type not handled.')),
        );
    }
  }

  String _formatDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
      return 'This Week';
    } else {
      return DateFormat('MMMM dd, yyyy').format(date); // Older than a week
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<AppNotification>> groupedNotifications = {};
    for (var notification in _notifications) {
      String groupKey = _formatDateGroup(notification.timestamp);
      groupedNotifications.putIfAbsent(groupKey, () => []).add(notification);
    }

    List<String> sortedGroupKeys = groupedNotifications.keys.toList();
    // Custom sort for date groups
    sortedGroupKeys.sort((a, b) {
      if (a == 'Today') return -1;
      if (b == 'Today') return 1;
      if (a == 'Yesterday') return -1;
      if (b == 'Yesterday') return 1;
      if (a == 'This Week') return -1;
      if (b == 'This Week') return 1;
      // For "Month Year" format, sort by actual date (descending)
      try {
        final DateFormat formatter = DateFormat('MMMM dd, yyyy'); // Use 'MMMM dd, yyyy' to parse
        final DateTime dateA = formatter.parse(a);
        final DateTime dateB = formatter.parse(b);
        return dateB.compareTo(dateA);
      } catch (e) {
        print('Error parsing date for sorting: $e');
        return b.compareTo(a); // Fallback to alphabetical if parsing fails
      }
    });


    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF141CC9),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('No new notifications.'))
          : ListView.builder(
        itemCount: sortedGroupKeys.length,
        itemBuilder: (context, groupIndex) {
          String groupKey = sortedGroupKeys[groupIndex];
          List<AppNotification> group = groupedNotifications[groupKey]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  groupKey,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.length,
                itemBuilder: (context, itemIndex) {
                  final notification = group[itemIndex];
                  return Card(
                    color: notification.isRead ? Colors.white : Colors.blue.shade50,
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: notification.senderProfilePictureUrl != null && notification.senderProfilePictureUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(notification.senderProfilePictureUrl!) as ImageProvider<Object>?
                            : const AssetImage('assets/default_profile.png') as ImageProvider<Object>?,
                        child: (notification.senderProfilePictureUrl == null || notification.senderProfilePictureUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
                      ),
                      subtitle: Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: (notification.type == NotificationType.message || notification.type == NotificationType.reply)
                          ? TextButton(
                        onPressed: () => _handleNotificationTap(notification),
                        child: const Text('View Message'),
                      )
                          : Text(
                        DateFormat('h:mm a').format(notification.timestamp), // Time only
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () => _handleNotificationTap(notification),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
