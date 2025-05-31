import 'package:flutter/material.dart';
import 'package:hanapp/models/message.dart'; // Ensure correct import path
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hanapp/viewmodels/chat_view_model.dart'; // Ensure correct import path
import 'package:geolocator/geolocator.dart'; // For location services
import 'package:url_launcher/url_launcher.dart'; // To open URLs
import 'package:hanapp/screens/map_screen.dart'; // Import the new MapScreen
// import 'package:hanapp_flutter/screens/review_screen.dart'; // REMOVE THIS IMPORT
import 'package:hanapp/widgets/review_dialog.dart'; // NEW: Import ReviewDialog

class UnifiedChatScreen extends StatefulWidget {
  const UnifiedChatScreen({super.key});

  @override
  State<UnifiedChatScreen> createState() => _UnifiedChatScreenState();
}

class _UnifiedChatScreenState extends State<UnifiedChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('UnifiedChatScreen: initState called.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('UnifiedChatScreen: didChangeDependencies called.');
    final chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    print('UnifiedChatScreen: Arguments received: $args');
    chatViewModel.initializeChat(args);
  }

  Future<void> _showBlockConfirmationDialog(BuildContext context, ChatViewModel chatViewModel) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block User?'),
          content: Text('Are you sure you want to block ${chatViewModel.recipientName ?? 'this user'}? You will no longer receive messages from them.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final response = await chatViewModel.blockUser();
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to block user: ${response['message']}')),
        );
      }
    }
  }

  Future<void> _viewCurrentLocation(BuildContext context, ChatViewModel chatViewModel) async {
    if (chatViewModel.recipientUser?.latitude == null || chatViewModel.recipientUser?.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipient location not available.')),
      );
      return;
    }

    final double lat = chatViewModel.recipientUser!.latitude!;
    final double lon = chatViewModel.recipientUser!.longitude!;
    final String recipientName = chatViewModel.recipientName ?? 'Recipient';

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in settings.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          latitude: lat,
          longitude: lon,
          title: '$recipientName\'s Location',
        ),
      ),
    );
  }

  Widget _buildMessage(Message message, int currentUserId, ChatViewModel chatViewModel) {
    final bool isMe = message.senderId == currentUserId;

    // Robust checks for system messages
    final bool isStartedProjectMessage = message.messageText.contains('started the project for ');
    final bool isMarkedDoneMessage = message.messageText.contains('marked the project') && message.messageText.contains('as done. Please confirm.');
    final bool isConfirmedCompletionMessage = message.messageText.contains('confirmed the completion of the project');

    final bool isSystemMessage = isStartedProjectMessage || isMarkedDoneMessage || isConfirmedCompletionMessage;

    // Determine the alignment of the message bubble
    final AlignmentGeometry alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    // Determine the background color of the message bubble
    final Color backgroundColor = isMe ? Colors.blue.shade100 : Colors.grey.shade200;

    // Debug prints to check conditions for button visibility
    print('--- Message Debug ---');
    print('Message Text: "${message.messageText}"');
    print('isSystemMessage (calculated): $isSystemMessage');
    print('isMarkedDoneMessage (calculated): $isMarkedDoneMessage');
    print('isConfirmedCompletionMessage (calculated): $isConfirmedCompletionMessage');
    print('chatViewModel.isLister: ${chatViewModel.isLister}');
    print('chatViewModel.applicationStatus: ${chatViewModel.applicationStatus}');
    print('---------------------');


    // System messages have a different styling and might contain buttons
    if (isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Center( // Center the system message bubble
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF141CC9), // System messages often have a neutral background
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Use min to wrap content
              children: [
                Text(
                  message.messageText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                // Show "Confirm" button only if it's the "marked as done" message AND the current user is the Lister
                // AND the application status is still 'completed_by_doer' (meaning it hasn't been confirmed yet)
                if (isMarkedDoneMessage && chatViewModel.isLister && chatViewModel.applicationStatus == 'completed_by_doer')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0), // Add some space above the button
                    child: ElevatedButton(
                      onPressed: () async {
                        // Call the updateApplicationStatus to 'completed'
                        final response = await chatViewModel.updateApplicationStatus('completed');
                        if (response['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response['message'])),
                          );
                          // No need to navigate back, just refresh the chat
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to confirm completion: ${response['message']}')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow, // Use HANAPP Blue for button
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),

                // Show "Leave a Review" button ONLY for the Lister after project is confirmed completed
                if (isConfirmedCompletionMessage && chatViewModel.isLister) // Condition: Lister only
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Show the review dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ReviewDialog(
                              reviewerId: chatViewModel.currentUser!.id, // Lister's ID
                              reviewedUserId: chatViewModel.recipientId!, // Doer's ID
                              listingId: chatViewModel.listingId,
                              listingTitle: chatViewModel.listingTitle,
                              reviewedUserName: chatViewModel.recipientName ?? 'Doer', // Pass the Doer's name
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600, // Green for review button
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      child: const Text('Leave a Review'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Regular chat messages
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.messageText,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 4.0),
            Text(
              DateFormat('hh:mm a').format(message.sentAt),
              style: TextStyle(fontSize: 10.0, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, chatViewModel, child) {
        if (chatViewModel.currentUser == null || chatViewModel.recipientId == null || chatViewModel.isLoadingMessages) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading Chat...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF141CC9),
            foregroundColor: Colors.white,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: chatViewModel.recipientUser?.profilePictureUrl != null && chatViewModel.recipientUser!.profilePictureUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(chatViewModel.recipientUser!.profilePictureUrl!) as ImageProvider<Object>?
                      : null,
                  child: (chatViewModel.recipientUser?.profilePictureUrl == null || chatViewModel.recipientUser!.profilePictureUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 25, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatViewModel.recipientName ?? 'Chat',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (chatViewModel.recipientUser?.addressDetails != null && chatViewModel.recipientUser!.addressDetails!.isNotEmpty)
                        Text(
                          chatViewModel.recipientUser!.addressDetails!,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (chatViewModel.listingTitle != null)
                        Text(
                          chatViewModel.listingTitle!,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'block') {
                    _showBlockConfirmationDialog(context, chatViewModel);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'block',
                    child: Text('Block User'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              if (chatViewModel.listingTitle != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
                  ),
                  child: Text(
                    chatViewModel.listingTitle!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Conditional UI for Lister (Reject/Start/Confirm Completion)
              // These buttons are for initial application management, not in-chat confirmation
              if (chatViewModel.isLister)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (chatViewModel.applicationStatus == 'pending')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final response = await chatViewModel.updateApplicationStatus('rejected');
                              if (response['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(response['message'])),
                                );
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to reject application: ${response['message']}')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                      SizedBox(width: chatViewModel.applicationStatus == 'pending' ? 16 : 0),
                      if (chatViewModel.applicationStatus == 'pending')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final response = await chatViewModel.updateApplicationStatus('ongoing');
                              if (response['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(response['message'])),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to start project: ${response['message']}')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Start'),
                          ),
                        ),
                    ],
                  ),
                ),

              // Doer's "Mark as Done" button (outside message bubble)
              if (!chatViewModel.isLister && chatViewModel.applicationStatus == 'ongoing')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final response = await chatViewModel.updateApplicationStatus('completed_by_doer');
                        if (response['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response['message'])),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to mark as done: ${response['message']}')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: const Text('Mark as Done'),
                    ),
                  ),
                ),

              // Status and View Location button (for ongoing/completed jobs)
              if (chatViewModel.applicationStatus == 'ongoing' ||
                  chatViewModel.applicationStatus == 'completed_by_doer' ||
                  chatViewModel.applicationStatus == 'completed')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(chatViewModel.applicationStatus).shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(chatViewModel.applicationStatus),
                          style: TextStyle(color: _getStatusColor(chatViewModel.applicationStatus).shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _viewCurrentLocation(context, chatViewModel),
                        icon: const Icon(Icons.location_on, color: Colors.white),
                        label: const Text('View Current Location', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  reverse: false,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: chatViewModel.messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(chatViewModel.messages[index], chatViewModel.currentUser!.id, chatViewModel);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        ),
                        onSubmitted: (value) async {
                          bool success = await chatViewModel.sendMessage(value);
                          if (success) {
                            _messageController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to send message.')),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    chatViewModel.isSendingMessage
                        ? const CircularProgressIndicator()
                        : FloatingActionButton(
                      onPressed: () async {
                        bool success = await chatViewModel.sendMessage(_messageController.text);
                        if (success) {
                          _messageController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to send message.')),
                          );
                        }
                      },
                      backgroundColor: const Color(0xFF141CC9),
                      mini: true,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'ongoing':
        return 'Ongoing';
      case 'completed_by_doer':
        return 'Marked Done (Awaiting Lister Confirmation)';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown Status';
    }
  }

  MaterialColor _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'accepted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'ongoing':
        return Colors.orange;
      case 'completed_by_doer':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
