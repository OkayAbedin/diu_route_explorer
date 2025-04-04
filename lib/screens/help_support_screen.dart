import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/sidebar.dart';

class HelpSupportScreen extends StatefulWidget {
  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String currentTime = '';
  Timer? _timer;

  // List of FAQs
  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I check the bus schedule?',
      'answer':
          'Select your preferred schedule type (Regular, Shuttle, or Friday) and then choose your route from the dropdown menu. The app will display all available start and departure times for that route.',
    },
    {
      'question': 'What do the different schedule types mean?',
      'answer':
          'Regular schedules are for normal weekdays (Saturday to Thursday), Shuttle schedules are for special shuttle services, and Friday schedules are specifically for Friday timings which may differ from regular weekdays.',
    },
    {
      'question': 'Can I set a default route?',
      'answer':
          'Yes! Go to Settings and select your preferred default route. This route will be automatically selected when you open the app next time.',
    },
    {
      'question': 'How do I get notifications about route changes?',
      'answer':
          'Make sure you have enabled push notifications in the Settings screen. The app will notify you about any changes to your favorite routes or general announcements.',
    },
    {
      'question': 'What should I do if the bus schedule is not loading?',
      'answer':
          'First, check your internet connection. If you\'re connected but still having issues, try using the refresh button at the top of the screen. The app also stores cached data that will be displayed if you\'re offline.',
    },
    {
      'question': 'How accurate are the bus timings?',
      'answer':
          'The timings are based on the official university schedule, but actual arrival and departure times may vary slightly due to traffic conditions or other unforeseen circumstances.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update time every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'DIU Route Explorers Support Request'},
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      print('Error launching email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open email app. Please copy the email address manually.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildSidebar(BuildContext context) {
    return Sidebar();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 88, 13, 218),
      endDrawer: _buildSidebar(context),
      body: Stack(
        children: [
          // Fixed purple header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              color: Color.fromARGB(255, 88, 13, 218),
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
                        'Help & Support',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder:
                        (context) => IconButton(
                          icon: Icon(Icons.menu, color: Colors.white, size: 30),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        ),
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
                color: Color.fromARGB(255, 88, 13, 218),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FAQ Section
                      Text(
                        'Frequently Asked Questions',
                        style: GoogleFonts.inter(
                          color: Color.fromARGB(255, 88, 13, 218),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // FAQ Expansion Panels
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: faqs.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                faqs[index]['question']!,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      faqs[index]['answer']!,
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 32),

                      // Contact Section
                      Text(
                        'Contact Us',
                        style: GoogleFonts.inter(
                          color: Color.fromARGB(255, 88, 13, 218),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      Text(
                        'If you have any questions or need assistance, please feel free to contact us:',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      SizedBox(height: 16),

                      // Email Cards
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 88, 13, 218),
                            child: Icon(Icons.email, color: Colors.white),
                          ),
                          title: Text(
                            'Support Email',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'abedin15-4919@diu.edu.bd',
                            style: GoogleFonts.inter(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () => _launchEmail('abedin15-4919@diu.edu.bd'),
                        ),
                      ),

                      SizedBox(height: 12),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 88, 13, 218),
                            child: Icon(Icons.email, color: Colors.white),
                          ),
                          title: Text(
                            'Support Email',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'garodia15-5048@diu.edu.bd',
                            style: GoogleFonts.inter(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap:
                              () => _launchEmail('garodia15-5048@diu.edu.bd'),
                        ),
                      ),

                      SizedBox(height: 24),

                      // App Information
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About DIU Route Explorers',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'DIU Route Explorers is designed to help Daffodil International University students navigate the university bus system efficiently. The app provides up-to-date information on bus routes, schedules, and important announcements.',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'App Version: 1.0.1',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
