/// Represents a span of time within a video for trimming purposes.
class TrimDurationSpan {
  /// Creates a [TrimDurationSpan] with a required start and end duration.
  const TrimDurationSpan({
    required this.start,
    required this.end,
  });

  /// The start time of the trim span.
  final Duration start;

  /// The end time of the trim span.
  final Duration end;

  /// Returns the total duration of the trim span.
  Duration get duration => end - start;
}
