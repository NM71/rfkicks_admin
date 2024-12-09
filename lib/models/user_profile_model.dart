class UserProfile {
  final String email;
  final String displayName;
  final String? profilePictureUrl;
  final String? address;
  final String? bio;
  final String? phoneNumber;
  final bool isProfileSetup;

  UserProfile({
    required this.email,
    required this.displayName,
    this.profilePictureUrl,
    this.address,
    this.bio,
    this.phoneNumber,
    required this.isProfileSetup,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['user_email'] ?? '',
      displayName: json['display_name'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
      address: json['address'],
      bio: json['bio'],
      phoneNumber: json['phone_number'],
      isProfileSetup: json['is_profile_setup'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'address': address,
      'bio': bio,
      'phone_number': phoneNumber,
    };
  }
}