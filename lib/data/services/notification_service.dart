import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Notification reçue en arrière-plan : ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // 1. Demander la permission (iOS & Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('⚠️ Permission de notification refusée');
      return;
    }

    // 2. Afficher les notifications même quand l'app est ouverte sur iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Sauvegarder le token FCM dès qu'un utilisateur est connecté
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _saveTokenToFirestore(user.uid);
      }
    });

    // 4. Mettre à jour le token s'il change
    _messaging.onTokenRefresh.listen((newToken) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _updateToken(uid, newToken);
      }
    });

    // 5. Afficher une bannière quand une notification arrive app ouverte
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        Get.snackbar(
          notification.title ?? 'Elbabor',
          notification.body ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  static Future<void> _saveTokenToFirestore(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _updateToken(uid, token);
      }
    } catch (e) {
      print('❌ Erreur récupération token FCM : $e');
    }
  }

  static Future<void> _updateToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
      print('✅ Token FCM sauvegardé pour $uid');
    } catch (e) {
      print('❌ Erreur sauvegarde token FCM : $e');
    }
  }
}