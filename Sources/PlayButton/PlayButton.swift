import UIKit

/// A button that can render four different modes and animate between them.
@IBDesignable
public class PlayButton: UIButton {
  /// The target state of the button.
  ///
  /// When the button is currently animating this is the mode it's animating to.
  public private(set) var mode: PlayButtonMode = .play

  override public var isEnabled: Bool {
    didSet {
      alpha = isEnabled ? 1.0 : 0.5
    }
  }

  override public var isHighlighted: Bool {
    didSet {
      setLayerHighlighted(isHighlighted)
    }
  }

  public override var canBecomeFocused: Bool { true }

  // MARK: Appearance

  /// The background color used for the pause and stop mode. Defaults to `lightGray`.
  @IBInspectable
  public var pauseStopBackgroundColor: UIColor? = .lightGray {
    didSet {
      updateColors()
    }
  }

  /// The color used for the pause and stop mode. Defaults to `black`.
  @IBInspectable
  public var pauseStopTintColor: UIColor? = .black {
    didSet {
      updateColors()
    }
  }

  /// The background color used for the play and buffering mode. Defaults to `lightGray`.
  @IBInspectable
  public var playBufferingBackgroundColor: UIColor? = .lightGray {
    didSet {
      updateColors()
    }
  }

  /// The color used for the triangle and the shape while buffering. Defaults to `black`.
  @IBInspectable
  public var playBufferingTintColor: UIColor? = .black {
    didSet {
      updateColors()
    }
  }

  /// Corner radius of the horizontal/vertical bars. Defaults to `3.0`.
  @IBInspectable
  public var barCornerRadius: CGFloat = 3.0

  /// Thickness of the horizontal/vertical bars. Use twice the ``barCornerRadius`` for a rounded line. Defaults to `6.0`.
  @IBInspectable
  public var barThickness: CGFloat = 6.0


  /// Corner radius of the square stop shape. Defaults to `1.5`
  @IBInspectable
  public var squareCornerRadius: CGFloat = 1.5

  /// The width of the square stop shape. Defaults to `15.0`
  @IBInspectable
  public var squareWidth: CGFloat = 15.0

  /// Corner radius of the play triangle shape. Defaults to `1.5`.
  @IBInspectable
  public var triangleCornerRadius: CGFloat = 1.5 {
    didSet {
      guard triangleCornerRadius != oldValue else { return }
      updateTrianglePath()
    }
  }

  /// The width of the triangle.  Defaults to `20.0`.
  @IBInspectable
  public var triangleWidth: CGFloat = 20.0 {
    didSet {
      guard triangleWidth != oldValue else { return }
      updateTrianglePath()
    }
  }

  // MARK: Initialization

  /// Initializes the button with a size of `(44.0, 44.0)`.
  public convenience init() {
    self.init(frame: CGRect(x: 0, y: 0, width: 44.0, height: 44.0))
  }

  /// Creates a new button with the specified frame.
  /// - Parameter frame: The frame rectangle for the view, measured in points.
  override public init(frame: CGRect) {
    super.init(frame: frame)

    commonInit()
  }

  /// Creates a new button with data in an unarchiver.
  /// - Parameter coder: An unarchiver object.
  required public init?(coder: NSCoder) {
    super.init(coder: coder)

    commonInit()
  }

  /// Sets the buttons’s current value, allowing you to animate the change visually.
  ///
  /// If you specify the same mode that the button is already in, nothing happens.
  ///
  /// - Parameters:
  ///   - mode: The new mode to assign to the ``mode`` property
  ///   - animated: Specify `true` to animate the change in value; otherwise, specify `false` to update the button's
  ///   appearance immediately. Animations are performed asynchronously and do not block the calling thread. When animating
  ///   to `buffering` the `animated` property only determines whether the transition to the horizontal bar is animated, the
  ///   actual buffering keyframe animation will always be run repeatedly. Defaults to `true`.
  ///
  ///   - Note:When the application is not in an active state the `animated` parameter is ignored.
  public func setMode(_ mode: PlayButtonMode, animated: Bool = true) {
    let shouldAnimate = UIApplication.shared.applicationState == .active && animated

    // if the change should be animated we only animate when there is a change
    if self.mode == mode && shouldAnimate { return }

    self.mode = mode

    if shouldAnimate {
      switch mode {
      case .pause:
        animateToPause()
      case .stop:
        animateToStop()
      case .play:
        animateToPlay()
      case .buffering:
        animateToBuffering()
      }

    } else {
      scaleLayer.sublayers?.forEach { $0.removeAllAnimations() }
      updateModelLayerForCurrentMode()
    }
  }

  override public func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)

    if newWindow != nil, newWindow != window {
      setMode(mode, animated: false)
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    var xScale = bounds.width / scaleLayer.bounds.width
    var yScale = bounds.height / scaleLayer.bounds.height

    switch contentMode {
    case .scaleToFill:
      break
    case .scaleAspectFill:
      let scale = max(xScale, yScale)
      xScale = scale
      yScale = scale
    default:
      let scale = min(xScale, yScale)
      xScale = scale
      yScale = scale
    }

    var xTranslate = (xScale - 1.0) * scaleLayer.bounds.height / 2.0
    var yTranslate = (yScale - 1.0) * scaleLayer.bounds.width / 2.0

    switch contentMode {
    case .scaleToFill:
      break
    case .scaleAspectFill:
      if bounds.width < bounds.height {
        xTranslate += (bounds.width - xScale * scaleLayer.bounds.width) / 2.0
      } else if bounds.width > bounds.height {
        yTranslate += (bounds.height - yScale * scaleLayer.bounds.height) / 2.0
      }
    default:
      if bounds.width > bounds.height {
        xTranslate += (bounds.width - xScale * scaleLayer.bounds.width) / 2.0
      } else if bounds.width < bounds.height {
        yTranslate += (bounds.height - yScale * scaleLayer.bounds.height) / 2.0
      }
    }

    scaleLayer.transform = CATransform3DConcat(
      CATransform3DMakeScale(xScale, yScale, 1),
      CATransform3DMakeTranslation(xTranslate, yTranslate, 0)
    )
  }

#if os(tvOS)
  public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)

    guard let nextFocusedView = context.nextFocusedView else { return }

    if nextFocusedView == self {
      self.becomeFocusedUsingAnimationCoordinator(coordinator: coordinator)
      self.addMotionEffects()
    } else {
      self.resignFocusUsingAnimationCoordinator(coordinator: coordinator)
      self.motionEffects = []
    }
  }
#endif

  // MARK: Non-Public Api

  /// Current animation state of the button
  ///
  /// Set right before animations are added to the layers and remaining as long as the animation state is running.
  private var currentAnimationState: AnimationState = .playToBar(.playIdle)

  private var enterForegroundObservation: Any?

  // MARK: Layers

  /// The left shape layer.
  ///
  /// Animations added to this layer are seen as primary animations which trigger subsequent animation groups once completed..
  private let leftShape = CAShapeLayer()

  /// The right shape layer.
  ///
  /// This layer mimics the path and color of the `leftShape` except when animating to the `.pause` mode where it animates to the right.
  /// Animations added to this layer are seen as secondary animations which won't trigger subsequent animation groups once completed.
  private let rightShape = CAShapeLayer()

  /// The background circle layer.
  ///
  /// The background circle layer  can animate to a new color when entering/exiting the horizontal bar state.
  private let backgroundCircle = CALayer()


  /// The foreground layer.
  ///
  /// The foreground layer is a child of the ``scaleLayer`` and contains the left and right shape layers.
  private let foregroundLayer = CALayer()

  /// The scale layer.
  ///
  /// The scale layer is used to scaled the child layers so the path parameters don't have to be recalculated. It is the only child of the
  /// button's layer and all animated layer are children of the scale layer.
  private let scaleLayer = CALayer()

  // MARK: Durations

  /// The default duration of one buffering animation cycle.
  ///
  /// The total amount of time it takes for one iteration of the buffering keyframe animation (horizontal bar, circle right, horizontal bar, circle left, horizontal bar).
  /// Defaults to `1.0`.
  ///
  /// - Note: The actual buffering duration depends on whether Slow Animations are enabled in the Simulator. See ``bufferingDuration``.
  private let defaultBufferingDuration: CFTimeInterval = 1.0

  /// The duration of one buffering animation cycle.
  ///
  /// This property takes the simulators Slow Animations setting into account.
  private var bufferingDuration: CFTimeInterval { simulatorDragCoefficient() * defaultBufferingDuration }

  /// The duration of an animation step.
  ///
  /// The amount of time it takes for an animation step like animating from the triangle path to the horizontal bar. To transition from one mode to another
  /// it typically takes multiple amounts of `animationStepDuration`s. Defaults to `0.2` times the ``bufferingDuration``.
  ///
  /// - Note: This property takes the simulators Slow Animations setting into account.
  private var animationStepDuration: CFTimeInterval { 0.2 * bufferingDuration }

  /// The duration of a background color animation.
  ///
  /// The amount of time it takes for the background color to change, i.e. when animating from the horizontal bar to the rounded sqaure (stop).
  /// Defaults to ``animationStepDuration``.
  ///
  /// - Note: This property takes the simulators Slow Animations setting into account.
  private var backgroundColorDuration: CFTimeInterval { animationStepDuration }

  private var shapeWidth: CGFloat { leftShape.bounds.width }
  private var shapeHeight: CGFloat { leftShape.bounds.height }

  /// This is the horizontal spacing between the end points of the triangle's first two bezier curves.
  /// It's used to calculate helper points along the straight lines of the bar and square paths.
  private var triangleBezierXSpacing: CGFloat = 0.0

  /// Cached path returend from the last `createTriangleWithVertices` call.
  private var currentTrianglePath: CGPath = CGPath(rect: .zero, transform: .none)

  /// Setting up the layer tree, gestures, pointer interactions etc.
  private func commonInit() {
    titleLabel?.isHidden = true

    // squeeze me, stretch me - I'll handle it
    contentMode = .scaleAspectFit
    setContentHuggingPriority(.defaultLow, for: .horizontal)
    setContentHuggingPriority(.defaultLow, for: .vertical)
    setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    setContentCompressionResistancePriority(.defaultLow, for: .vertical)

    layer.addSublayer(scaleLayer)

    scaleLayer.masksToBounds = true
    scaleLayer.name = "scaleLayer"

    scaleLayer.addSublayer(backgroundCircle)
    scaleLayer.addSublayer(foregroundLayer)
    foregroundLayer.addSublayer(leftShape)
    foregroundLayer.addSublayer(rightShape)

    [scaleLayer, backgroundCircle, foregroundLayer, leftShape, rightShape].forEach {
      $0.frame = CGRect(x: 0, y: 0, width: 44.0, height: 44.0)
    }
    backgroundCircle.cornerRadius = 22.0
    backgroundCircle.name = "backgroundCircle"
    foregroundLayer.name = "foregroundLayer"

    // calculate initial triangle path
    updateTrianglePath()

    setMode(.play, animated: false)

    enterForegroundObservation = NotificationCenter.default.addObserver(
      forName: UIApplication.willEnterForegroundNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }
      self.setMode(self.mode, animated: false)
    }

    #if os(tvOS)
      scaleLayer.masksToBounds = false
    #else
      if #available(macCatalyst 13.0, iOS 13.0, *) {
        addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(hover)))
      }

      if #available(macCatalyst 13.4, iOS 13.4, *) {
        isPointerInteractionEnabled = true
        pointerStyleProvider = { [weak self] _, _, _ in
          guard let self = self else { return nil }

          let path = UIBezierPath(ovalIn: self.backgroundCircle.bounds)
          path.apply(self.layer.affineTransform())
          let params = UIPreviewParameters()
          params.visiblePath = path

          let preview = UITargetedPreview(view: self, parameters: params)

          return UIPointerStyle(effect: .automatic(preview), shape: .path(path))
        }
      }
    #endif
  }

#if !os(tvOS)
  @available(macCatalyst 13.0, iOS 13.0, *)
  @objc
  private func hover(gesture: UIHoverGestureRecognizer) {
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: [.allowUserInteraction],
      animations: {
        switch gesture.state {
        case .began, .changed:
          self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1)
        case .ended:
          self.layer.transform = CATransform3DIdentity

        default: break
        }
      },
      completion: nil
    )
  }
#endif

  private func updateColors() {
    CATransaction.withoutAnimation {
      switch mode {
      case .play, .buffering:
        leftShape.fillColor = playBufferingTintColor?.cgColor
        rightShape.fillColor = playBufferingTintColor?.cgColor
        backgroundCircle.backgroundColor = playBufferingBackgroundColor?.cgColor
      case .pause, .stop:
        leftShape.fillColor = pauseStopTintColor?.cgColor
        rightShape.fillColor = pauseStopTintColor?.cgColor
        backgroundCircle.backgroundColor = pauseStopBackgroundColor?.cgColor
      }
    }
  }

  private func setLayerHighlighted(_ shouldHighlight: Bool) {
    #if os(tvOS)
      UIView.animate(
        withDuration: 0.1,
        delay: 0,
        options: [.allowUserInteraction, .beginFromCurrentState],
        animations: { [unowned self] in
          if shouldHighlight {
            self.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1)
          } else if self.isFocused {
            self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1)
          } else {
            self.layer.transform = CATransform3DIdentity
          }

          self.setShadowActive(self.isFocused && !shouldHighlight)
        },
        completion: nil
      )
    #else
      let scale: CGFloat = shouldHighlight ? 0.92 : 1.0
      backgroundCircle.transform = CATransform3DMakeScale(scale, scale, 1)
      foregroundLayer.transform = CATransform3DMakeScale(scale, scale, 1)
    #endif
  }

  private func updateModelLayerForCurrentMode() {
    CATransaction.withoutAnimation {
      switch mode {
      case .play, .buffering:
        leftShape.transform = CATransform3DMakeRotation(0, 0.0, 0.0, 1.0)
        leftShape.fillColor = playBufferingTintColor?.cgColor
        backgroundCircle.backgroundColor = playBufferingBackgroundColor?.cgColor
      case .pause:
        leftShape.transform = CATransform3DMakeRotation(deg2rad(90), 0.0, 0.0, 1.0)
        leftShape.fillColor = pauseStopTintColor?.cgColor
        backgroundCircle.backgroundColor = pauseStopBackgroundColor?.cgColor
      case .stop:
        leftShape.transform = CATransform3DMakeRotation(deg2rad(90), 0.0, 0.0, 1.0)
        leftShape.fillColor = pauseStopTintColor?.cgColor
        backgroundCircle.backgroundColor = pauseStopBackgroundColor?.cgColor
      }

      rightShape.transform = leftShape.transform
      rightShape.fillColor = leftShape.fillColor
      leftShape.path = shapePath(isLeft: true)
      rightShape.path = shapePath(isLeft: false)
    }

    switch mode {
    case .buffering:
      currentAnimationState = .buffering(.buffering)
      nextAnimation(basedOn: .playToBar(.triangleToBar))?.run()
    case .play:
      currentAnimationState = .playToBar(.playIdle)
    case .pause:
      currentAnimationState = .pauseToBar(.pauseIdle)
    case .stop:
      currentAnimationState = .stopToBar(.stopIdle)
    }
  }

  // MARK: Paths

  // ▶️
  /// The path of the triangle is only calculated when necessary and cached in ``currentTrianglePath``.
  private func updateTrianglePath() {
    let γ₁ = -(deg2rad(180) - 2.0 * atan(1.0 / 2.0)) // top left
    let γ₂ = CGFloat(0) // middle right
    let γ₃ = deg2rad(180) - (2.0 * atan(1.0 / 2.0)) // bottom left

    let r: CGFloat = 5.0 / 8.0 * triangleWidth
    let centerOffset = shapeWidth / 2.0 - r

    let px: (CGFloat, CGFloat) -> CGFloat = { r, γ in
      r * (1.0 + cos(γ)) + centerOffset
    }
    let py: (CGFloat, CGFloat) -> CGFloat = { r, γ in
      r * (1.0 + sin(γ)) + centerOffset
    }

    let topLeft = CGPoint(x: px(r, γ₁), y: py(r, γ₁))
    let middleRight = CGPoint(x: px(r, γ₂), y: py(r, γ₂))
    let bottomLeft = CGPoint(x: px(r, γ₃), y: py(r, γ₃))

    let (path, offset) = CGPath.createTriangleWithVertices(
      upperLeftCorner: topLeft,
      rightCorner: middleRight,
      lowerLeftCorner: bottomLeft,
      cornerRadius: triangleCornerRadius
    )

    currentTrianglePath = path
    triangleBezierXSpacing = offset

    // recalculate paths for current mode
    setMode(mode, animated: false)
  }

  // ━ ┃ ·
  private func horizontalBarPath(centerYOffset: CGFloat = 0, circleMode: BarCircleMode? = nil) -> CGPath {
    let width = triangleWidth
    let triangleBoundingBox = CGRect(
      x: (shapeWidth - width) / 2.0,
      y: (shapeHeight - barThickness) / 2.0,
      width: width,
      height: barThickness
    )

    let xOffset = circleMode != nil ? triangleBezierXSpacing : 0.0
    let barThicknessHalved = barThickness / 2.0
    let centerY = shapeHeight / 2.0 + centerYOffset
    let rightCenter = circleMode == .left
    ? CGPoint(x: triangleBoundingBox.minX + barCornerRadius, y: centerY)
    : CGPoint(x: triangleBoundingBox.maxX - barCornerRadius, y: centerY)
    let leftCenter = circleMode == .right
    ? CGPoint(x: triangleBoundingBox.maxX - barCornerRadius, y: centerY)
    : CGPoint(x: triangleBoundingBox.minX + barCornerRadius, y: centerY)
    let leftTop = leftCenter.applying(CGAffineTransform(translationX: xOffset, y: -barThicknessHalved))
    let leftBottom = leftCenter.applying(CGAffineTransform(translationX: xOffset, y: barThicknessHalved))

    let line = CGMutablePath()
    line.addArc(center: leftCenter, radius: barCornerRadius, startAngle: deg2rad(180), endAngle: deg2rad(270), clockwise: false)
    line.addLine(to: leftTop)
    line.addArc(center: rightCenter, radius: barCornerRadius, startAngle: deg2rad(270), endAngle: deg2rad(0), clockwise: false)
    line.addArc(center: rightCenter, radius: barCornerRadius, startAngle: deg2rad(0), endAngle: deg2rad(90), clockwise: false)
    line.addLine(to: leftBottom)
    line.addArc(center: leftCenter, radius: barCornerRadius, startAngle: deg2rad(90), endAngle: deg2rad(180), clockwise: false)
    line.closeSubpath()

    return line
  }

  // ⏸
  private func pausePath(isLeft: Bool) -> CGPath {
    horizontalBarPath(centerYOffset: 2.0 * (isLeft ? barCornerRadius : -barCornerRadius))
  }

  // ⏹
  private func squarePath() -> CGPath {
    let width: CGFloat = squareWidth
    let triangleBoundingBox = CGRect(
      x: (shapeWidth - width) / 2.0,
      y: (shapeHeight - barThickness) / 2.0,
      width: width,
      height: barThickness
    )

    let centerY = shapeHeight / 2.0
    let rightCenter = CGPoint(x: triangleBoundingBox.maxX - squareCornerRadius, y: centerY)
    let leftCenter = CGPoint(x: triangleBoundingBox.minX + squareCornerRadius, y: centerY)
    let leftTop = leftCenter.applying(CGAffineTransform(translationX: 0, y: -squareCornerRadius))
    let leftBottom = leftCenter.applying(CGAffineTransform(translationX: 0, y: squareCornerRadius))

    let offset = (width - 2.0 * squareCornerRadius) / 2.0
    let leftCenterHigher = leftCenter.applying(CGAffineTransform(translationX: 0, y: -offset))
    let leftCenterLower = leftCenter.applying(CGAffineTransform(translationX: 0, y: offset))
    let leftTopHigher = leftTop.applying(CGAffineTransform(translationX: triangleBezierXSpacing, y: -offset))
    let leftBottomLower = leftBottom.applying(CGAffineTransform(translationX: triangleBezierXSpacing, y: offset))
    let rightCenterHigher = rightCenter.applying(CGAffineTransform(translationX: 0, y: -offset))
    let rightCenterLower = rightCenter.applying(CGAffineTransform(translationX: 0, y: offset))

    let line = CGMutablePath()
    line.addArc(center: leftCenterHigher, radius: squareCornerRadius, startAngle: deg2rad(180), endAngle: deg2rad(270), clockwise: false)
    line.addLine(to: leftTopHigher)
    line.addArc(center: rightCenterHigher, radius: squareCornerRadius, startAngle: deg2rad(270), endAngle: deg2rad(0), clockwise: false)
    line.addArc(center: rightCenterLower, radius: squareCornerRadius, startAngle: deg2rad(0), endAngle: deg2rad(90), clockwise: false)
    line.addLine(to: leftBottomLower)
    line.addArc(center: leftCenterLower, radius: squareCornerRadius, startAngle: deg2rad(90), endAngle: deg2rad(180), clockwise: false)
    line.closeSubpath()

    return line
  }

  private func shapePath(for mode: PlayButtonMode? = nil, isLeft: Bool) -> CGPath {
    switch mode ?? self.mode {
    case .pause:
      return pausePath(isLeft: isLeft)
    case .play:
      return currentTrianglePath
    case .buffering:
      return horizontalBarPath()
    case .stop:
      return squarePath()
    }
  }
}

// MARK: Convenience

public extension PlayButton {
  /// Returns  whether the `mode` is `.stop`.
  var isStop: Bool { mode == .stop }

  /// Returns  whether the `mode` is `.play`.
  var isPlay: Bool { mode == .play }

  /// Returns  whether the `mode` is `.pause`.
  var isPause: Bool { mode == .pause }

  /// Returns  whether the `mode` is `.buffering`.
  var isBuffering: Bool { mode == .buffering }

  /// A convenience function to toggle between stop and play
  func setStop(_ shouldStop: Bool, animated: Bool = true) {
    guard isStop != shouldStop || animated == false else { return }

    setMode(shouldStop ? .stop : .play, animated: animated)
  }
}

// MARK: CAAnimationDelegate

extension PlayButton: CAAnimationDelegate {
  public func animationDidStop(_ anim: CAAnimation, finished hasFinished: Bool) {
    guard anim.isKeyframe, hasFinished else { return }

    if let next = nextAnimation(basedOn: currentAnimationState) {
      currentAnimationState = next.run()
    }
  }
}

// MARK: - Animation Steps

private extension PlayButton {
  private func animateToPause() {
    switch currentAnimationState {
      // already in the right direction
    case .playToBar(.triangleToBar),
        .barToPause,
        .buffering(.toBar),
        .stopToBar(.barRotateHorizontal),
        .stopToBar(.barShrink):
      break

      // already at destination (shouldn't happen)
    case .pauseToBar(.pauseIdle):
      assertionFailure()

      // all the states that are in the wrong direction
    case .pauseToBar(.barsMerge):
      guard let animations = nextAnimation(basedOn: .barToPause(.barRotateVertical)) else { return }
      currentAnimationState = animations.run()

    case .barToStop(.barRotateVertical):
      guard let animations = nextAnimation(basedOn: .stopToBar(.barShrink)) else { return }
      currentAnimationState = animations.run()

    case .pauseToBar(.barRotateHorizontal):
      guard let animations = nextAnimation(basedOn: .playToBar(.triangleToBar)) else { return }
      guard mode == .pause else { fatalError("next animation step depends on the mode being .pause") }
      currentAnimationState = animations.run()

      // starting from triangle -> trigger initial animation
    case .playToBar(.playIdle), .barToPlay(.play), .barToPlay(.barToTriangle):
      guard let animations = nextAnimation(basedOn: .playToBar(.playIdle)) else { return }
      currentAnimationState = animations.run()

      // starting from stop -> trigger initial animation
    case .barToStop(.barExpand), .barToStop(.stop), .stopToBar(.stopIdle):
      guard let animations = nextAnimation(basedOn: .stopToBar(.stopIdle)) else { return }
      currentAnimationState = animations.run()

      // stop buffering and return to horizontal bar
    case .buffering(.buffering):
      guard let animations = nextAnimation(basedOn: currentAnimationState) else { return }
      currentAnimationState = animations.run()
    }
  }

  private func animateToStop() {
    switch currentAnimationState {
      // already in the right direction
    case .playToBar(.triangleToBar),
        .barToStop,
        .buffering(.toBar),
        .pauseToBar(.barsMerge),
        .pauseToBar(.barRotateHorizontal):
      break

      // already at destination (shouldn't happen)
    case .stopToBar(.stopIdle):
      assertionFailure()

      // all the states that are in the wrong direction
    case .barToPause(.barRotateVertical):
      guard let animations = nextAnimation(basedOn: .pauseToBar(.barsMerge)) else { return }
      currentAnimationState = animations.run()

    case .stopToBar(.barShrink):
      guard let animations = nextAnimation(basedOn: .barToStop(.barRotateVertical)) else { return }
      currentAnimationState = animations.run()

    case .stopToBar(.barRotateHorizontal):
      guard let animations = nextAnimation(basedOn: .playToBar(.triangleToBar)) else { return }
      guard mode == .stop else { fatalError("next animation step depends on the mode being .stop") }
      currentAnimationState = animations.run()

      // starting from triangle -> trigger initial animation
    case .playToBar(.playIdle), .barToPlay(.play), .barToPlay(.barToTriangle):
      guard let animations = nextAnimation(basedOn: .playToBar(.playIdle)) else { return }
      currentAnimationState = animations.run()

      // stop buffering and return to horizontal bar
    case .buffering(.buffering):
      guard let animations = nextAnimation(basedOn: currentAnimationState) else { return }
      currentAnimationState = animations.run()

      // starting from pause -> trigger initial animation
    case .barToPause(.barSplit), .barToPause(.pause), .pauseToBar(.pauseIdle):
      guard let animations = nextAnimation(basedOn: .pauseToBar(.pauseIdle)) else { return }
      currentAnimationState = animations.run()
    }
  }

  private func animateToPlay() {
    switch currentAnimationState {
      // already in the right direction
    case .stopToBar(.barShrink),
        .stopToBar(.barRotateHorizontal),
        .pauseToBar(.barsMerge),
        .pauseToBar(.barRotateHorizontal),
        .buffering(.toBar),
        .barToPlay:
      break

      // already at destination (shouldn't happen)
    case .playToBar(.playIdle):
      assertionFailure()

      // all the states that are in the wrong direction
    case .barToPause(.barRotateVertical):
      guard let animations = nextAnimation(basedOn: .pauseToBar(.barsMerge)) else { return }
      currentAnimationState = animations.run()

    case .barToStop(.barRotateVertical):
      guard let animations = nextAnimation(basedOn: .stopToBar(.barShrink)) else { return }
      currentAnimationState = animations.run()

    case .playToBar(.triangleToBar):
      guard let animations = nextAnimation(basedOn: .playToBar(.triangleToBar)) else { return }
      guard mode == .play else { fatalError("next animation step depends on the mode being .play") }
      currentAnimationState = animations.run()

      // starting from pause -> trigger initial animation
    case .barToPause(.barSplit), .barToPause(.pause), .pauseToBar(.pauseIdle):
      guard let animations = nextAnimation(basedOn: .pauseToBar(.pauseIdle)) else { return }
      currentAnimationState = animations.run()

      // starting from stop -> trigger initial animation
    case .barToStop(.barExpand), .barToStop(.stop), .stopToBar(.stopIdle):
      guard let animations = nextAnimation(basedOn: .stopToBar(.stopIdle)) else { return }
      currentAnimationState = animations.run()

      // stop buffering and return to horizontal bar
    case .buffering(.buffering):
      guard let animations = nextAnimation(basedOn: currentAnimationState) else { return }
      currentAnimationState = animations.run()
    }
  }

  private func animateToBuffering() {
    switch currentAnimationState {
      // already in the right direction
    case .playToBar(.triangleToBar),
        .pauseToBar(.barsMerge),
        .pauseToBar(.barRotateHorizontal),
        .stopToBar(.barShrink),
        .stopToBar(.barRotateHorizontal):
      break

      // already at destination (shouldn't happen)
    case .buffering(.buffering):
      assertionFailure()

      // all the states that are in the wrong direction
    case .buffering(.toBar):
      // reverse buffering to bar -> any animation that has bar as destination value
      guard let animations = nextAnimation(basedOn: .playToBar(.triangleToBar)) else { return }
      currentAnimationState = animations.run()

    case .barToStop(.barRotateVertical):
      guard let animations = nextAnimation(basedOn: .stopToBar(.barShrink)) else { return }
      currentAnimationState = animations.run()

    case .barToPause(.barRotateVertical):
      guard let animations = nextAnimation(basedOn: .pauseToBar(.barsMerge)) else { return }
      currentAnimationState = animations.run()

    case .playToBar(.playIdle), .barToPlay(.play), .barToPlay(.barToTriangle):
      guard let animations = nextAnimation(basedOn: .playToBar(.playIdle)) else { return }
      currentAnimationState = animations.run()

    case .barToPause(.barSplit), .barToPause(.pause), .pauseToBar(.pauseIdle):
      guard let animations = nextAnimation(basedOn: .pauseToBar(.pauseIdle)) else { return }
      currentAnimationState = animations.run()

    case .barToStop(.barExpand), .barToStop(.stop), .stopToBar(.stopIdle):
      guard let animations = nextAnimation(basedOn: .stopToBar(.stopIdle)) else { return }
      currentAnimationState = animations.run()
    }
  }

  // swiftlint:disable:next function_body_length
  func nextAnimation(basedOn state: AnimationState) -> AnimationGroup? {
    switch state {
    case .playToBar(.playIdle):
      return AnimationGroup(
        animations: [(leftShape, triangleToBarAnimation(isLeft: true)), (rightShape, triangleToBarAnimation(isLeft: false))],
        resultState: .playToBar(.triangleToBar)
      )
    case .playToBar(.triangleToBar), .pauseToBar(.barRotateHorizontal), .buffering(.toBar), .stopToBar(.barRotateHorizontal):

      // we are idle so now it depends on the current mode
      switch mode {
      case .buffering:
        // animations are for the circles to get the correct color
        return AnimationGroup(
          animations: [(leftShape, bufferingAnimation(isLeft: true)), (rightShape, bufferingAnimation(isLeft: false))],
          resultState: .buffering(.buffering)
        )

      case .pause, .stop:
        let animations = [
          (leftShape, barRotateVerticalAnimation(isLeft: true)),
          (rightShape, barRotateVerticalAnimation(isLeft: false)),
          (leftShape, barRotateVerticalShapeColorAnimation),
          (rightShape, barRotateVerticalShapeColorAnimation),
          (backgroundCircle, barRotateVerticalBackgroundColorAnimation)
        ] as [(CALayer, CAAnimation)]
        return AnimationGroup(
          animations: animations,
          resultState: mode == .pause ? .barToPause(.barRotateVertical) : .barToStop(.barRotateVertical)
        )

      case .play:
        return AnimationGroup(
          animations: [(leftShape, barToTriangleAnimation(isLeft: true)), (rightShape, barToTriangleAnimation(isLeft: false))],
          resultState: .barToPlay(.barToTriangle)
        )
      }

    case .barToPlay(.barToTriangle): // noop just state change
      return AnimationGroup(animations: [], resultState: .barToPlay(.play))

    case .barToPause(.barSplit): // noop just state change
      return AnimationGroup(animations: [], resultState: .barToPause(.pause))

    case .barToStop(.barExpand): // noop just state change
      return AnimationGroup(animations: [], resultState: .barToStop(.stop))

    case .barToPause(.barRotateVertical):
      return AnimationGroup(
        animations: [(leftShape, splitBarAnimation(isLeft: true)), (rightShape, splitBarAnimation(isLeft: false))],
        resultState: .barToPause(.barSplit)
      )

    case .pauseToBar(.pauseIdle):
      return AnimationGroup(
        animations: [(leftShape, mergeBarsAnimation(isLeft: true)), (rightShape, mergeBarsAnimation(isLeft: false))],
        resultState: .pauseToBar(.barsMerge)
      )

    case .barToStop(.barRotateVertical):
      return AnimationGroup(
        animations: [(leftShape, expandBarAnimation(isLeft: true)), (rightShape, expandBarAnimation(isLeft: false))],
        resultState: .barToStop(.barExpand)
      )

    case .stopToBar(.stopIdle):
      return AnimationGroup(
        animations: [(leftShape, shrinkBarAnimation(isLeft: true)), (rightShape, shrinkBarAnimation(isLeft: false))],
        resultState: .stopToBar(.barShrink)
      )

    case .pauseToBar(.barsMerge):
      switch mode {
      case .stop:
        return AnimationGroup(
          animations: [(leftShape, expandBarAnimation(isLeft: true)), (rightShape, expandBarAnimation(isLeft: false))],
          resultState: .barToStop(.barExpand)
        )
      default:
        let animations = [
          (leftShape, barRotateHorizontalAnimation(isLeft: true)),
          (rightShape, barRotateHorizontalAnimation(isLeft: false)),
          (leftShape, barRotateHorizontalShapeColorAnimation),
          (rightShape, barRotateHorizontalShapeColorAnimation),
          (backgroundCircle, barRotateHorizontalBackgroundColorAnimation)
        ] as [(CALayer, CAAnimation)]
        return AnimationGroup(
          animations: animations,
          resultState: state == .pauseToBar(.barsMerge) ? .pauseToBar(.barRotateHorizontal) : .stopToBar(.barRotateHorizontal)
        )
      }

    case .stopToBar(.barShrink):
      // if animating to pause we can take the fast past of splitting now
      switch mode {
      case .pause:
        return AnimationGroup(
          animations: [(leftShape, splitBarAnimation(isLeft: true)), (rightShape, splitBarAnimation(isLeft: false))],
          resultState: .barToPause(.barSplit)
        )
      default:
        let animations = [
          (leftShape, barRotateHorizontalAnimation(isLeft: true)),
          (rightShape, barRotateHorizontalAnimation(isLeft: false)),
          (leftShape, barRotateHorizontalShapeColorAnimation),
          (rightShape, barRotateHorizontalShapeColorAnimation),
          (backgroundCircle, barRotateHorizontalBackgroundColorAnimation)
        ] as [(CALayer, CAAnimation)]
        return AnimationGroup(
          animations: animations,
          resultState: .stopToBar(.barRotateHorizontal)
        )
      }

    case .buffering(.buffering):
      if mode != .buffering {
        let animations = [
          (leftShape, bufferingToBar(isLeft: true)),
          (rightShape, bufferingToBar(isLeft: false))
        ]
        return AnimationGroup(
          animations: animations,
          resultState: .buffering(.toBar)
        )

      } else {
        return nil
      }

    case .barToPlay(.play), .barToPause(.pause), .barToStop(.stop):
      return nil
    }
  }

  // MARK: Play -> Buffering -> Stop/Pause

  private func triangleToBarAnimation(isLeft: Bool) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
    animation.animationKey = isLeft ? .triangleToHorizontalBar : .triangleToHorizontalBarRight
    animation.toValue = horizontalBarPath()
    animation.duration = animationStepDuration
    animation.delegate = self
    return animation
  }

  private func barRotateVerticalAnimation(isLeft: Bool) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
    animation.animationKey = isLeft ? .barRotateVertical : .barRotateVerticalRight
    animation.toValue = CATransform3DMakeRotation(deg2rad(90), 0, 0, 1)
    animation.duration = animationStepDuration
    animation.delegate = self
    return animation
  }

  /// runs concurrently with `barRotateVerticalAnimation`.
  private var barRotateVerticalShapeColorAnimation: CABasicAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.fillColor))
    animation.animationKey = .barRotateVerticalShapeColor
    animation.toValue = pauseStopTintColor?.cgColor
    animation.duration = animationStepDuration
    animation.delegate = self
    return animation
  }

  /// runs concurrently with `barRotateVerticalAnimation`.
  private var barRotateVerticalBackgroundColorAnimation: CABasicAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))
    animation.animationKey = .barRotateVerticalBackgroundColor
    animation.toValue = pauseStopBackgroundColor?.cgColor
    animation.duration = animationStepDuration
    animation.delegate = self
    return animation
  }

  private func splitBarAnimation(isLeft: Bool) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
    animation.animationKey = isLeft ? .splitBar : .splitBarRight
    animation.toValue = pausePath(isLeft: isLeft)
    animation.duration = animationStepDuration
    animation.delegate = self
    return animation
  }

  private func expandBarAnimation(isLeft: Bool) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
    animation.animationKey = isLeft ? .expandBar : .expandBarRight
    animation.toValue = squarePath()
    animation.duration = animationStepDuration
    animation.delegate = self
    return animation
  }

  // MARK: Stop/Pause -> Buffering -> Play

  private func shrinkBarAnimation(isLeft: Bool) -> CABasicAnimation {
    let forwardAnimation = expandBarAnimation(isLeft: isLeft) // since `toValue` is the same, the side doesn't matter
    forwardAnimation.toValue = horizontalBarPath()
    forwardAnimation.animationKey = isLeft ? .shrinkBar : .shrinkBarRight
    return forwardAnimation
  }

  private func mergeBarsAnimation(isLeft: Bool) -> CABasicAnimation {
    let forwardAnimation = splitBarAnimation(isLeft: isLeft) // since `toValue` is the same, the side doesn't matter
    forwardAnimation.toValue = horizontalBarPath()
    forwardAnimation.animationKey = isLeft ? .mergeBars : .mergeBarsRight
    return forwardAnimation
  }

  private func barRotateHorizontalAnimation(isLeft: Bool) -> CABasicAnimation {
    let forwardAnimation = barRotateVerticalAnimation(isLeft: isLeft)
    forwardAnimation.toValue = CATransform3DIdentity
    forwardAnimation.animationKey = isLeft ? .barRotateHorizontal : .barRotateHorizontalRight
    return forwardAnimation
  }

  /// runs concurrently with `barRotateHorizontalAnimation`.
  private var barRotateHorizontalShapeColorAnimation: CABasicAnimation {
    let forwardAnimation = barRotateVerticalShapeColorAnimation
    forwardAnimation.animationKey = .barRotateHorizontalShapeColor
    forwardAnimation.toValue = playBufferingTintColor?.cgColor
    return forwardAnimation
  }

  /// runs concurrently with `barRotateHorizontalAnimation`.
  private var barRotateHorizontalBackgroundColorAnimation: CABasicAnimation {
    let forwardAnimation = barRotateVerticalBackgroundColorAnimation
    forwardAnimation.animationKey = .barRotateHorizontalBackgroundColor
    forwardAnimation.toValue = playBufferingBackgroundColor?.cgColor
    return forwardAnimation
  }

  private func barToTriangleAnimation(isLeft: Bool) -> CABasicAnimation {
    let forwardAnimation = triangleToBarAnimation(isLeft: isLeft)
    forwardAnimation.animationKey = isLeft ? .barToTriangle : .barToTriangleRight
    forwardAnimation.toValue = currentTrianglePath
    return forwardAnimation
  }

  // MARK: Buffering Animation

  private func bufferingAnimation(isLeft: Bool) -> CAKeyframeAnimation {
    let animation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.path))
    animation.values = [
      horizontalBarPath(),
      horizontalBarPath(circleMode: .right),
      horizontalBarPath(),
      horizontalBarPath(circleMode: .left),
      horizontalBarPath()
    ]

    animation.repeatCount = .greatestFiniteMagnitude
    animation.duration = bufferingDuration
    animation.delegate = self

    animation.animationKey = isLeft ? .buffering : .bufferingRight

    return animation
  }

  private func bufferingToBar(isLeft: Bool) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
    animation.animationKey = isLeft ? .bufferingToBar : .bufferingToBarRight
    animation.toValue = horizontalBarPath()
    animation.duration = animationStepDuration
    animation.delegate = self
    return animation
  }
}

/// When the horizontal bar shrinks to a circle during buffering it can be on the left or the right
private enum BarCircleMode: Int {
  case left, right
}

