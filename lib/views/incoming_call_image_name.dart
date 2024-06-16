import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class IncomingManageController extends GetxController{

  String name = '';
  String image = 'Default';

  setValue(name,image){
    this.name = name;
    this.image = image;
    update();
  }

  removeValue(){
    this.name = '';
    this.image = 'Default';
    update();
  }

  String callingImage = 'Default';
  String callingName = '';

  callingImageUpdate({required String image,required String name}){
    print('call image update call');
    print('image is ${image}');
    print('name is ${name}');
    callingName = name;
    callingImage = image;
    update();
  }

  removecallingImageValue(){
    callingName = '';
    callingImage = 'Default';
    update();
  }

}