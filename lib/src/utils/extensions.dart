extension PercentageExtensions on num {
  num addPercentage(num percent) => this + (this * percent).abs();

  num removePercentage(num percent) => this - (this * percent).abs();
}
