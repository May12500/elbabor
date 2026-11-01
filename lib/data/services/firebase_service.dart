import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static FirebaseFirestore get firestore => _firestore;

  static String? get currentUserId => _auth.currentUser?.uid;
  static User? get currentUser => _auth.currentUser;

  // Get current user's basic info from Firebase Auth
  static String? get currentUserEmail => _auth.currentUser?.email;
  static String? get currentUserName => _auth.currentUser?.displayName;

  // Get complete user data from Firestore
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = currentUserId;
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Get user role
  static Future<String?> getCurrentUserRole() async {
    final userData = await getCurrentUserData();
    return userData?['role'];
  }

  // Get user's full name (from Firestore)
  static Future<String?> getUserFullName() async {
    final userData = await getCurrentUserData();
    return userData?['fullName'] ?? userData?['name'] ?? currentUserName;
  }

  // Get user's email (prefer Firestore, fallback to Auth)
  static Future<String?> getUserEmail() async {
    final userData = await getCurrentUserData();
    return userData?['email'] ?? currentUserEmail;
  }

  // Get user's phone number
  static Future<String?> getUserPhone() async {
    final userData = await getCurrentUserData();
    return userData?['phone'] ?? userData?['phoneNumber'];
  }

  // Get complete user profile
  static Future<UserProfile?> getUserProfile() async {
    final userData = await getCurrentUserData();
    if (userData == null) return null;

    return UserProfile(
      uid: currentUserId!,
      fullName: userData['fullName'] ?? userData['name'] ?? currentUserName ?? 'Unknown',
      email: userData['email'] ?? currentUserEmail ?? 'No email',
      phone: userData['phone'] ?? userData['phoneNumber'] ?? 'No phone',
      role: userData['role'] ?? 'passenger',
    );
  }

  // Stream for real-time user data updates
  static Stream<DocumentSnapshot> get userDataStream {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }
}

// User Profile Model
class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      fullName: data['fullName'] ?? data['name'] ?? 'Unknown',
      email: data['email'] ?? 'No email',
      phone: data['phone'] ?? data['phoneNumber'] ?? 'No phone',
      role: data['role'] ?? 'passenger',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}