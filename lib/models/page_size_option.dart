enum PageSizeOption {
  original,
  a4,
  letter;

  String get label {
    switch (this) {
      case PageSizeOption.original: return 'Original / Image Fit';
      case PageSizeOption.a4: return 'A4';
      case PageSizeOption.letter: return 'Letter';
    }
  }
}
