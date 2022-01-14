/// A visual mode a play button can be in.
public enum Mode: Int {
  /// The mode indicates a buffering state.
  case buffering

  /// The mode indicates a button tap triggers pause (two vertical bars).
  case pause

  /// The mode indicates a button tap triggers play (triangle).
  case play

  /// The mode indicates a button tap triggers stop (square).
  case stop
}
