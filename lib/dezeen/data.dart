class DataQuran {
  final String suraName;
  final String fileName;
  final bool isQuranfile;
  final String? content; // New optional field for direct API content

  DataQuran({
    required this.fileName,
    required this.isQuranfile,
    required this.suraName,
    this.content,
  });
}
