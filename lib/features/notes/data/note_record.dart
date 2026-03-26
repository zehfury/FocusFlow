class NoteRecord {
  const NoteRecord({
    required this.title,
    required this.content,
    required this.timestampEpochMs,
  });

  final String title;
  final String content;

  /// Updated-at timestamp (epoch milliseconds).
  final int timestampEpochMs;

  DateTime get timestamp =>
      DateTime.fromMillisecondsSinceEpoch(timestampEpochMs);

  NoteRecord copyWith({
    String? title,
    String? content,
    int? timestampEpochMs,
  }) {
    return NoteRecord(
      title: title ?? this.title,
      content: content ?? this.content,
      timestampEpochMs: timestampEpochMs ?? this.timestampEpochMs,
    );
  }
}

