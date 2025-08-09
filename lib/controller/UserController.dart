import 'package:get/get.dart';

class UserController extends GetxController {
  var name = ''.obs;
  var photoUrl = ''.obs;

  void setUserData(String userName, String userPhoto) {
    name.value = userName;
    photoUrl.value = userPhoto;
    print("📌 UserController -> Name: $userName, PhotoURL: $userPhoto");
  }
}
