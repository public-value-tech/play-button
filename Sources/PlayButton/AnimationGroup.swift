import UIKit

/// Simple wrapper to group animations and their target layer with the resulting animation state.
struct AnimationGroup {
  /// A mapping from the animations to their target layer
  let animations: [(CALayer, CAAnimation)]
  /// The state resulting from running the animation
  let resultState: AnimationState

  @discardableResult
  func run() -> AnimationState {
    animations.forEach {
      if let basicAnimation = $0.1 as? CABasicAnimation {
        $0.0.addBasicAnimationSyncingModelWithPresentationLayer(animation: basicAnimation)
      } else if let keyframeAnimation = $0.1 as? CAKeyframeAnimation {
        $0.0.addKeyframeAnimationSyncingModelWithPresentationLayer(animation: keyframeAnimation)
      }
    }

    return resultState
  }
}
