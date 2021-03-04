class Place {
  final String name;
  final bool isClosed;

  const Place({required this.name, this.isClosed = false});

  @override
  String toString() {
    return 'Place $name (closed : $isClosed)';
  }
}
