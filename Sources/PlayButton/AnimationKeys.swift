import UIKit

extension PlayButton {
  struct AnimationKey: RawRepresentable, Equatable, Hashable {
    static let key = "animation_key"

    let rawValue: String

    init(_ rawValue: String) {
      self.init(rawValue: rawValue)
    }

    init(rawValue: String) {
      self.rawValue = rawValue
    }

    // play to pause
    static let triangleToHorizontalBar = AnimationKey("triangle_to_horizontal_bar")
    static let triangleToHorizontalBarRight = AnimationKey("triangle_to_horizontal_bar_right")
    static let barRotateVertical = AnimationKey("bar_rotate_vertical")
    static let barRotateVerticalRight = AnimationKey("bar_rotate_vertical_right")
    static let barRotateVerticalShapeColor = AnimationKey("bar_rotate_vertical_shape_color")
    static let barRotateVerticalBackgroundColor = AnimationKey("bar_rotate_vertical_background_color")
    static let splitBar = AnimationKey("split_bar")
    static let splitBarRight = AnimationKey("split_bar_right")
    static let expandBar = AnimationKey("expand_bar")
    static let expandBarRight = AnimationKey("expand_bar_right")

    // pause to play
    static let mergeBars = AnimationKey("merge_bars")
    static let mergeBarsRight = AnimationKey("merge_bars_right")
    static let barRotateHorizontal = AnimationKey("bar_rotate_horizontal")
    static let barRotateHorizontalRight = AnimationKey("bar_rotate_horizontal_right")
    static let barRotateHorizontalShapeColor = AnimationKey("bar_rotate_horizontal_shape_color")
    static let barRotateHorizontalBackgroundColor = AnimationKey("bar_rotate_horizontal_background_color")
    static let barToTriangle = AnimationKey("bar_to_triangle")
    static let barToTriangleRight = AnimationKey("bar_to_triangle_right")

    // stop to play
    static let shrinkBar = AnimationKey("shrink_bar")
    static let shrinkBarRight = AnimationKey("shrink_bar_right")

    // buffering
    static let buffering = AnimationKey("buffering")
    static let bufferingRight = AnimationKey("buffering_right")
    static let bufferingToBar = AnimationKey("buffering_to_bar")
    static let bufferingToBarRight = AnimationKey("buffering_to_bar_right")
  }
}

extension CAAnimation {
  var animationKey: PlayButton.AnimationKey? {
    get {
      (value(forKey: PlayButton.AnimationKey.key) as? String).map(PlayButton.AnimationKey.init(_:))
    }
    set {
      setValue(newValue?.rawValue, forKey: PlayButton.AnimationKey.key)
    }
  }

  /// Keyframe animations are animations that are the main animation step of an animation group and that should trigger subsequent animations
  /// once they are completed. For example, all animations to the right shape layer are secondary animations since they run alognside the left
  /// shape layer animations.
  var isKeyframe: Bool {
    guard let key = animationKey else { return false }
    return [
      PlayButton.AnimationKey.triangleToHorizontalBar,
      .barRotateVertical,
      .splitBar,
      .mergeBars,
      .expandBar,
      .shrinkBar,
      .barRotateHorizontal,
      .barToTriangle,
      .buffering,
      .bufferingToBar
    ].contains(key)
  }
}
