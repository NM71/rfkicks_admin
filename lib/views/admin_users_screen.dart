import 'package:flutter/material.dart';
import 'package:rfkicks_admin/services/admin_api_service.dart';
import 'package:rfkicks_admin/views/custom_widgets/custom_snackbar.dart';
import 'package:rfkicks_admin/views/custom_widgets/my_button.dart';
import 'package:shimmer/shimmer.dart';

class AdminUsersScreen extends StatefulWidget {
  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserData> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final fetchedUsers = await AdminApiService.getUsers();
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _handleDeleteUser(UserData user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        backgroundColor: const Color(0xccf2f2f2),
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.black, fontSize: 17)),
          ),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text('Delete')),
          // TextButton(
          //   onPressed: () => Navigator.pop(context, true),
          //   child: Text('Delete', style: TextStyle(color: Colors.red)),
          // ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminApiService.deleteUser(user.id);
        CustomSnackbar.show(
          context: context,
          message: 'User deleted successfully',
        );
        loadUsers(); // Refresh the list
      } catch (e) {
        CustomSnackbar.show(
          context: context,
          message: 'Failed to delete user: $e',
          // isError: true,
        );
      }
    }
  }

  Future<void> _handleUpdateStatus(UserData user, int newStatus) async {
    try {
      await AdminApiService.updateUserStatus(user.id, newStatus);
      CustomSnackbar.show(
        context: context,
        message: 'User status updated successfully',
      );
      loadUsers(); // Refresh the list
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'Failed to update status: $e',
        // isError: true,
      );
    }
  }

// Shimmer Effect
  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[500]!,
          highlightColor: Colors.grey[300]!,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            color: Colors.white.withOpacity(0.75),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: Color(0xff3c76ad),
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                ),
                title: Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                ),
                subtitle: Container(
                  height: 16,
                  width: 160,
                  margin: EdgeInsets.only(top: 8),
                  color: Colors.white,
                ),
                trailing: Container(
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Header
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text(
                'User Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  loadUsers();
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Total Users: ${users.length}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  opacity: 0.3,
                  image: AssetImage('assets/images/rfkicks_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // if (isLoading)
          //   Center(
          //     child: CircularProgressIndicator(
          //       color: Color(0xff3c76ad),
          //     ),
          //   )
          SafeArea(
              child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: isLoading
                    ? _buildShimmerEffect()
                    : error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  error!,
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                MyButton(
                                  text: 'Retry',
                                  onTap: loadUsers,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return UserCard(
                                user: user,
                                onDelete: () => _handleDeleteUser(user),
                                onUpdateStatus: (status) =>
                                    _handleUpdateStatus(user, status),
                              );
                            },
                          ),
              )
            ],
          )),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserData user;
  final VoidCallback onDelete;
  final Function(int) onUpdateStatus;

  const UserCard({
    Key? key,
    required this.user,
    required this.onDelete,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withOpacity(0.75),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: Color(0xff3c76ad),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xff3c76ad),
            backgroundImage: user.profilePicture != null
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null
                ? Text(
                    user.displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            user.displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff3c76ad),
            ),
          ),
          subtitle: Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          trailing: PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Color(0xff3c76ad),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: ListTile(
                  leading: Icon(Icons.visibility, color: Color(0xff3c76ad)),
                  title: Text('View Details'),
                ),
              ),
              PopupMenuItem(
                value: 'status',
                child: ListTile(
                  leading: Icon(Icons.toggle_on, color: Color(0xff3c76ad)),
                  title: Text('Toggle Status'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'view':
                  _showUserDetails(context);
                  break;
                case 'status':
                  onUpdateStatus(user.status == 0 ? 1 : 0);
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
          ),
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Username', user.username),
                  _buildInfoRow('Registered', user.registered),
                  _buildInfoRow(
                    'Status',
                    user.status == 0 ? 'Active' : 'Inactive',
                    textColor: user.status == 0 ? Colors.green : Colors.red,
                  ),
                  if (user.address != null)
                    _buildInfoRow('Address', user.address!),
                  if (user.shoeSize != null)
                    _buildInfoRow('Shoe Size', user.shoeSize!),
                  if (user.bio != null) _buildInfoRow('Bio', user.bio!),
                  if (user.dateOfBirth != null)
                    _buildInfoRow('Birth Date', user.dateOfBirth!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context) async {
    try {
      final userDetails = await AdminApiService.getUserDetails(user.id);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: Text('User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('ID', userDetails.id.toString()),
                _buildInfoRow('Username', userDetails.username),
                _buildInfoRow('Email', userDetails.email),
                _buildInfoRow('Display Name', userDetails.displayName),
                _buildInfoRow('Registered', userDetails.registered),
                if (userDetails.address != null)
                  _buildInfoRow('Address', userDetails.address!),
                if (userDetails.shoeSize != null)
                  _buildInfoRow('Shoe Size', userDetails.shoeSize!),
                if (userDetails.bio != null)
                  _buildInfoRow('Bio', userDetails.bio!),
                if (userDetails.dateOfBirth != null)
                  _buildInfoRow('Birth Date', userDetails.dateOfBirth!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'Failed to load user details: $e',
        // isError: true,
      );
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff3c76ad),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor ?? Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Update the UserData class by adding the status field:
class UserData {
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String registered;
  final String? profilePicture;
  final String? address;
  final String? shoeSize;
  final String? bio;
  final String? dateOfBirth;
  final int status; // Added status field

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.registered,
    this.profilePicture,
    this.address,
    this.shoeSize,
    this.bio,
    this.dateOfBirth,
    required this.status, // Added to constructor
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: int.parse(json['ID'].toString()),
      username: json['user_login'],
      email: json['user_email'],
      displayName: json['display_name'],
      registered: json['user_registered'],
      profilePicture: json['profile_picture'] != null
          ? 'https://rfkicks.com/api/${json['profile_picture']}' // Add base URL
          : null,
      address: json['address'],
      shoeSize: json['shoe_size'],
      bio: json['bio'],
      dateOfBirth: json['date_of_birth'],
      status: int.parse(json['user_status']?.toString() ?? '0'),
    );
  }
}
