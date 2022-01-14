import UIKit

extension PlayButton {
  func addMotionEffects() {
    // layer
    let tiltValue: CGFloat = 0.1

    let xTilt = UIInterpolatingMotionEffect(keyPath: "layer.transform.rotation.x", type: .tiltAlongHorizontalAxis)
    xTilt.minimumRelativeValue = -tiltValue
    xTilt.maximumRelativeValue = tiltValue

    let yTilt = UIInterpolatingMotionEffect(keyPath: "layer.transform.rotation.y", type: .tiltAlongVerticalAxis)
    yTilt.minimumRelativeValue = -tiltValue
    yTilt.maximumRelativeValue = tiltValue

    // background
    let backgroundPanValue: CGFloat = 2.0

    let backgroundXPan = UIInterpolatingMotionEffect(keyPath: "sublayers.scaleLayer.sublayers.backgroundCircle.position.x", type: .tiltAlongHorizontalAxis)
    backgroundXPan.minimumRelativeValue = -backgroundPanValue
    backgroundXPan.maximumRelativeValue = backgroundPanValue

    let backgroundYPan = UIInterpolatingMotionEffect(keyPath: "sublayers.scaleLayer.sublayers.backgroundCircle.position.y", type: .tiltAlongVerticalAxis)
    backgroundYPan.minimumRelativeValue = -backgroundPanValue
    backgroundYPan.maximumRelativeValue = backgroundPanValue

    let foregroundPanValue: CGFloat = 1.0

    // foreground
    let foregroundXPan = UIInterpolatingMotionEffect(keyPath: "sublayers.scaleLayer.sublayers.foregroundLayer.position.x", type: .tiltAlongHorizontalAxis)
    foregroundXPan.minimumRelativeValue = -foregroundPanValue
    foregroundXPan.maximumRelativeValue = foregroundPanValue

    let foregroundYPan = UIInterpolatingMotionEffect(keyPath: "sublayers.scaleLayer.sublayers.foregroundLayer.position.y", type: .tiltAlongVerticalAxis)
    foregroundYPan.minimumRelativeValue = -foregroundPanValue
    foregroundYPan.maximumRelativeValue = foregroundPanValue

    let motionGroup = UIMotionEffectGroup()
    motionGroup.motionEffects = [
      xTilt,
      yTilt,
      backgroundXPan,
      backgroundYPan,
      foregroundXPan,
      foregroundYPan
    ]

    addMotionEffect( motionGroup )
  }

  func setShadowActive(_ shouldActivate: Bool) {
    if shouldActivate {
      self.layer.shadowColor = UIColor.black.cgColor
      self.layer.shadowOffset = CGSize(width: 5, height: 25)
      self.layer.shadowOpacity = 0.3
      self.layer.shadowRadius = 5
    } else {
      self.layer.shadowColor = nil
      self.layer.shadowOffset = .zero
    }
  }

  func becomeFocusedUsingAnimationCoordinator(coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({ () -> Void in
      self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
      self.layer.shadowColor = UIColor.black.cgColor
      self.layer.shadowOffset = CGSize(width: 5, height: 25)
      self.layer.shadowOpacity = 0.3
      self.layer.shadowRadius = 5
    })
  }

  func resignFocusUsingAnimationCoordinator(coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({ () -> Void in
      self.transform = .identity
      self.layer.shadowColor = nil
      self.layer.shadowOffset = .zero
    })
  }
}
