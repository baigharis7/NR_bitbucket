import 'dart:math';

class ImageHelper {
  String getImageForRecipe() {
    final randomNumber = Random().nextInt(5);
    return 'assets/images/recipe_image$randomNumber.png';
  }

  List<String> getImagesList(int listSize) {
    final list = <String>[];
    for (var i = 0; i <= listSize; i++) {
      list.add(ImageHelper().getImageForRecipe());
    }

    return list;
  }
}