class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data;
  final String? nextPageUrl;
  final bool hasMore;
  final int total;

  PaginatedResponse({
    required this.currentPage,
    required this.data,
    required this.nextPageUrl,
    required this.total,
  }) : hasMore = nextPageUrl != null;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      currentPage: json['current_page'],
      data: (json['data'] as List).map((item) => fromJsonT(item)).toList(),
      nextPageUrl: json['next_page_url'],
      total: int.parse(json['total'].toString()),
    );
  }
}
