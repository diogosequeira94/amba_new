extension NameExtensions on String {
  String getFirstAndLastName() {
    final names = trim().split(' ');
    print(names);
    final length = names.length;
    if(length == 1){
      return names[0];
    }
    return '${names[0]} ${names[length-1]}';
  }
}
