mport 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jobtask/screens/auth/sign_in_screen.dart';
import 'package:jobtask/screens/home_screen.dart';
import 'package:jobtask/screens/profile/user_profile.dart';
import 'package:jobtask/screens/shop/shop_screen.dart';
import 'package:jobtask/startup_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String token;

  const DashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ServicePage(),
    Center(child: Text('Cart Screen')),
    UserProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SearchDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        leading: Image.asset('assets/images/header2-2-1.png'),
        backgroundColor: const Color(0xffffffff),
        actions: [
          GestureDetector(
            onTap: () async {
              showSearchDialog(context);
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.search),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final storage = FlutterSecureStorage();
              await storage.delete(key: 'auth_token'); // Clear the stored token
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => StartupScreen()),
                (route) => false,
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.logout,
              ),
            ),
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Image.asset(
              'assets/icons/home_icon.png',
              height: 30,
              width: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Image.asset(
              'assets/icons/shop_icon.png',
              height: 30,
              width: 30,
            ),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Image.asset(
              'assets/icons/cart_icon.png',
              height: 30,
              width: 30,
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Image.asset(
              'assets/icons/profile_icon.png',
              height: 30,
              width: 30,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Service> _filteredServices = [];
  final List<Service> services = [
    Service('ReFresh', 30, 'assets/images/services_images/refresh_service.jpg'),
    Service('ReVive', 50, 'assets/images/services_images/revive_service.jpg'),
    Service('ReStore', 150, 'assets/images/services_images/restore_service.jpg'),
    Service('Kids Shoe', 150, 'assets/images/services_images/kids_service.jpg'),
    Service('Lace Cleaning', 20, 'assets/images/services_images/laceCleaning_service.jpg'),
    Service('Lint Removal', 20, 'assets/images/services_images/lintRemove_service.jpg'),
    Service('Reglue', 40, 'assets/images/services_images/reglue_service.jpg'),
    Service('RePaint', 70, 'assets/images/services_images/repaint_service.jpg'),
    Service('Un-Yellowing', 70, 'assets/images/services_images/unYellowing_service.jpg'),
    Service('Sole-Swaps', 80, 'assets/images/services_images/soleSwaps_service.jpg'),
  ];

  void _filterServices(String query) {
    final filtered = services.where((service) {
      return service.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredServices = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Search Services'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _filterServices,
            decoration: InputDecoration(hintText: 'Enter service name'),
          ),
          SizedBox(height: 10),
          Container(
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                return ListTile(
                  title: Text(service.name),
                  subtitle: Text('\$${service.price}'),
                  leading: Image.asset(service.imagePath, height: 50, width: 50),
                  onTap: () {
                    Navigator.of(context).pop(); // Close dialog
                    // You can navigate to a service details page here if needed
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}

class Service {
  final String name;
  final double price;
  final String imagePath;

  Service(this.name, this.price, this.imagePath);
}
