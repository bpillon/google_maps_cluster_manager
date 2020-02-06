class Boundaries {
  final double min, max;

  const Boundaries(double a, double b)
      : min = a > b ? b : a,
        max = a > b ? a : b;
}
