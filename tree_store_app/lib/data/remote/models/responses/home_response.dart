class UiBlockResponse {
  final String id;
  final String blockType;
  final String? title;
  final Map<String, dynamic> payload;
  final int sortOrder;

  const UiBlockResponse({
    required this.id,
    required this.blockType,
    this.title,
    this.payload = const {},
    this.sortOrder = 0,
  });

  factory UiBlockResponse.fromJson(Map<String, dynamic> json) {
    return UiBlockResponse(
      id: json['id'] as String? ?? '',
      blockType: json['blockType'] as String? ?? '',
      title: json['title'] as String?,
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

class HomeSduiResponse {
  final List<UiBlockResponse> blocks;

  const HomeSduiResponse({this.blocks = const []});

  factory HomeSduiResponse.fromJson(Map<String, dynamic> json) {
    final list = json['blocks'] as List<dynamic>? ?? [];
    return HomeSduiResponse(
      blocks: list.map((e) => UiBlockResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

</parameter>