import 'package:Caption_Calling/features/Article/articlepage.dart';
import 'package:Caption_Calling/features/drawer%20Widgets/earn_with_us.dart';
import 'package:Caption_Calling/features/drawer%20Widgets/hire_people.dart';
import 'package:Caption_Calling/features/home/widgets/banner_widget.dart';
import 'package:Caption_Calling/features/home/widgets/buttongrid.dart';
import 'package:Caption_Calling/features/home/widgets/webviewscreen.dart';
import 'package:Caption_Calling/features/login/login_page.dart';
import 'package:Caption_Calling/features/profile/create_account.dart';
import 'package:Caption_Calling/features/teams/create_teams_page.dart';
import 'package:Caption_Calling/features/teams/join_teams_page.dart';
import 'package:Caption_Calling/features/teams/myteams.dart';
import 'package:Caption_Calling/features/teams/tournment.dart';
import 'package:Caption_Calling/features/vedio/blog.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Replace with your LoginScreen import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens to navigate to based on the selected bottom nav index
  final List<Widget> _screens = [
    const HomeScreen(), // Home screen
    const BlogScreen(), // My Teams screen
    const ArticleScreen(), // Article screen
    const TournamentPage(), // Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to handle Logout
  void _logout(BuildContext context) async {
    // Remove the 'isLoggedIn' flag from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.clear();
    // Navigate to LoginScreen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Captain Calling',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              // _onProfileTap(context);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context), // Adding the Drawer
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 250,
              width: double.infinity,
              child: RunningBannerWidget(),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: ButtonGrid(onButtonTap: (String buttonType) {
                _onButtonPress(context, buttonType);
              }),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        unselectedItemColor: Colors.green,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Tournament',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_back),
            label: 'video',
          ),
        ],
      ),
    );
  }

  // Drawer Widget (Sidebar Menu)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            accountName: Text('User'),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/logo.png'), // Replace with your image path
            ),
            otherAccountsPictures: [
              Icon(Icons.person_add_alt_1, color: Colors.white),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share app'),
            onTap: () {
              Share.share(
                  'Prove your game! Download Captain Calling now https://play.google.com/store/apps/details?id=com.captain.calling1&pcampaignid=web_share and accept the challenge!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Earn With us'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EarnWithUsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WebViewScreen(
                            title: 'About Us',
                            url: 'https://captaincalling.com/about-us',
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text('Rate Us'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person_search),
            title: const Text('Hire People'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HirePeopleScreen()));
            },
          ),
          ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WebViewScreen(
                              title: 'Contact Us',
                              url: 'https://captaincalling.com/contact',
                            )));
              }),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Term and Conditions'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WebViewScreen(
                            title: 'Terms and Conditions',
                            url: 'https://captaincalling.com/terms-conditions',
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WebViewScreen(
                            title: 'Privacy Policy',
                            url: 'https://captaincalling.com/privacy-policy',
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _logout(context); // Calling the logout function
            },
          ),
        ],
      ),
    );
  }

  // Button Actions
  void _onButtonPress(BuildContext context, String buttonType) {
    switch (buttonType) {
      case 'Create Team':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CreateTeamScreen(
                    userId: '',
                    primarySports: [],
                  )),
        );
        break;
      case 'Article':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArticleScreen()),
        );
        break;
      case 'My Teams':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyTeamPage()),
        );
        break;
      case 'Join Team':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JoinTeamPage()),
        );
        break;
      default:
        break;
    }
  }

  // Profile Tap
  void _onProfileTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountScreen()),
    );
  }
}
