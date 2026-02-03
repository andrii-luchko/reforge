class PlatesEntity {
  PlatesEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.loreBody,
    required this.unlockLevel,
    required this.isLocked,
  });

  final int id;
  final String name;
  final String title;
  final String? imageUrl;
  final String? loreBody;
  final int unlockLevel;
  final bool isLocked;

  List<String> get loreSteps {
    return loreBody == null ? <String>[] : loreBody!.split(RegExp(r'\n\s*\n')).toList();
  }
}
