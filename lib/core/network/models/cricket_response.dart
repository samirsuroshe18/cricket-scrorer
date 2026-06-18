class CricketResponse<T> {
  final String? message;
  final T? data;

  const CricketResponse({required this.message, this.data});
}
