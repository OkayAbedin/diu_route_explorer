import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import 'dart:async';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) => _updateTime());

    // Initialize notification provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().initialize();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final hourString = hour == 0 ? '12' : hour.toString();
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    setState(() {
      currentTime = '$hourString:$minute $period';
    });
  }

  Future<void> _refreshNotifications() async {
    final notificationProvider = context.read<NotificationProvider>();
    await notificationProvider.refresh();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatNotificationDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recent';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'route_update':
      case 'update':
        return Icons.directions_bus;
      case 'schedule_change':
        return Icons.schedule;
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type, bool isDarkMode) {
    switch (type.toLowerCase()) {
      case 'route_update':
      case 'update':
        return Colors.blue;
      case 'schedule_change':
        return Colors.orange;
      case 'info':
        return Colors.green;
      case 'warning':
        return Colors.red;
      default:
        return isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = Color.fromARGB(255, 88, 13, 218);
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final borderColor =
        isDarkMode
            ? Colors.grey.shade700.withOpacity(0.5)
            : Colors.grey.shade300;

    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Scaffold(
          backgroundColor: primaryColor,
          endDrawer: Sidebar(),
          body: Stack(
            children: [
              // Fixed purple header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  color: primaryColor,
                  padding: EdgeInsets.only(
                    top: 60,
                    bottom: 15,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (notificationProvider.unreadCount > 0)
                            Text(
                              '${notificationProvider.unreadCount} unread',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed:
                                notificationProvider.isLoading
                                    ? null
                                    : _refreshNotifications,
                          ),
                          if (notificationProvider.notifications.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.clear_all,
                                color: Colors.white,
                                size: 26,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(''),
                                        content: Text(''),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: Text('Clear All'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  await notificationProvider.clearAll();
                                }
                              },
                            ),
                          Builder(
                            builder:
                                (context) => IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable content area
              Positioned(
                top: 140,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child:
                        notificationProvider.isLoading
                            ? Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                            : notificationProvider.notifications.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_none,
                                    size: 64,
                                    color:
                                        isDarkMode
                                            ? Colors.grey[600]
                                            : Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '',
                                    style: GoogleFonts.inter(
                                      color:
                                          isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '',
                                    style: GoogleFonts.inter(
                                      color:
                                          isDarkMode
                                              ? Colors.grey[500]
                                              : Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount:
                                  notificationProvider.notifications.length,
                              itemBuilder: (context, index) {
                                final notification =
                                    notificationProvider.notifications[index];
                                final isRead = notification['isRead'] ?? false;
                                final notificationType =
                                    notification['type'] ?? 'general';

                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color:
                                        isRead
                                            ? backgroundColor
                                            : (isDarkMode
                                                ? Colors.grey[800]
                                                : Colors.blue[50]),
                                    border: Border.all(
                                      color:
                                          isRead
                                              ? borderColor
                                              : primaryColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      if (!isRead) {
                                        await notificationProvider.markAsRead(
                                          notification['id'],
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Notification icon
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _getNotificationColor(
                                                notificationType,
                                                isDarkMode,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _getNotificationIcon(
                                                notificationType,
                                              ),
                                              color: _getNotificationColor(
                                                notificationType,
                                                isDarkMode,
                                              ),
                                              size: 20,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          // Notification content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        notification['title'] ??
                                                            '',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor,
                                                            ),
                                                      ),
                                                    ),
                                                    if (!isRead)
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  primaryColor,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  notification['message'] ?? '',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey[300]
                                                            : Colors.grey[700],
                                                    height: 1.4,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  _formatNotificationDate(
                                                    notification['timestamp'] ??
                                                        DateTime.now()
                                                            .toIso8601String(),
                                                  ),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey[500]
                                                            : Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
