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

  /// Slug usado no nome do ficheiro da foto do sócio.
  ///
  /// Primeiro + último nome, sem acentos, em minúsculas e separados por "-".
  /// Ex.: "Plínio Costa Fonseca" -> "plinio-fonseca"
  ///
  /// As fotos em assets/ foram renomeadas com estas mesmas regras, por isso
  /// qualquer alteração aqui obriga a renomear também os ficheiros.
  String toPhotoSlug() {
    final parts = trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

    if (parts.isEmpty) return '';

    final first = parts.first;
    final last = parts.length > 1 ? parts.last : '';
    final raw = last.isEmpty ? first : '$first-$last';

    return _stripAccents(raw).toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }

  /// Caminho do asset com a foto do sócio, ou null se o nome não der um slug.
  String? toPhotoAssetPath() {
    final slug = toPhotoSlug();
    return slug.isEmpty ? null : 'assets/$slug.jpg';
  }
}

const _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

String _stripAccents(String input) {
  final buffer = StringBuffer();

  for (final ch in input.split('')) {
    final lower = ch.toLowerCase();
    final replacement = _accents[lower];

    if (replacement == null) {
      buffer.write(ch);
    } else {
      // Mantém a caixa original; o toLowerCase() final trata do resto.
      buffer.write(ch == lower ? replacement : replacement.toUpperCase());
    }
  }

  return buffer.toString();
}
