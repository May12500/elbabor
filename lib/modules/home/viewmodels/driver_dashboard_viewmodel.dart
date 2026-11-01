import 'package:get/get.dart';

class DriverDashboardViewModel extends GetxController {

  final currentIndex = 0.obs;
  final hasUnreadMessages = false.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
  void checkUnreadMessages() async {
    // Implement your logic to check for unread messages
    // For example:
    // hasUnreadMessages.value = await messageService.hasUnreadMessages();
  }
}
