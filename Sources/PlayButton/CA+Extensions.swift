import UIKit

extension CATransaction {
  static func withoutAnimation(_ block: () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    block()
    CATransaction.commit()
  }
}

extension CALayer {
  func addBasicAnimationSyncingModelWithPresentationLayer(animation: CABasicAnimation, forKey key: String? = nil) {
    guard let keypath = animation.keyPath else { fatalError("animation needs a keypath") }

    let isCurrentlyAnimatingProperty = (self.animation(forKey: keypath) ?? key.flatMap { self.animation(forKey: $0) }) != nil
    let referenceLayer = isCurrentlyAnimatingProperty ? (presentation() ?? self) : self
    animation.fromValue = referenceLayer.value(forKey: keypath)

    // update the property in advance
    // NOTE: this approach will only work if toValue != nil
    CATransaction.withoutAnimation {
      setValue(animation.toValue, forKey: keypath)
    }

    add(animation, forKey: key ?? keypath)
  }

  func addKeyframeAnimationSyncingModelWithPresentationLayer(animation: CAKeyframeAnimation, forKey key: String? = nil) {
    guard let keypath = animation.keyPath else { fatalError("animation needs a keypath") }
    // if the property is not currently animated we just use the model layer to get the current value
    let isCurrentlyAnimatingProperty = (self.animation(forKey: keypath) ?? key.flatMap { self.animation(forKey: $0) }) != nil
    let referenceLayer = isCurrentlyAnimatingProperty ? (presentation() ?? self) : self
    let currentValue = referenceLayer.value(forKey: keypath)

    if var values = animation.values, (values.first as? NSValue) != (currentValue as? NSValue), let currentValue = currentValue {
      // first value should be the current presentation value
      values[0] = currentValue
      animation.values = values
    }

    // update the property in advance
    // NOTES: this approach will only work if values != nil
    CATransaction.withoutAnimation {
      setValue(animation.values?.last, forKey: keypath)
    }

    add(animation, forKey: key ?? keypath)
  }
}

#if DEBUG && (arch(i386) || arch(x86_64)) && os(iOS)
  @_silgen_name("UIAnimationDragCoefficient") func UIAnimationDragCoefficient() -> Float
  func simulatorDragCoefficient() -> CFTimeInterval {
    let drag = UIAnimationDragCoefficient()
    if drag > 1 {
      return CFTimeInterval(drag)
    }
    return 1
  }

#else
  func simulatorDragCoefficient() -> CFTimeInterval { 1 }
#endif
