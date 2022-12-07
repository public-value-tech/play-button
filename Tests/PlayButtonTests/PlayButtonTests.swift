@testable import PlayButton
import SnapshotTesting
import XCTest

@available(iOS 13.0.0, *)
final class PlayButtonTests: XCTestCase {
  var windowView: UIView!
  private var window: UIWindow!

  override func setUp() {
    super.setUp()

    guard UIDevice.current.name == "iPhone 11" else {
      fatalError("We need iPhone 11 for the snapshot tests")
    }

    window = UIWindow()
    let vc = UIViewController()
    window.rootViewController = vc
    window.makeKeyAndVisible()
    windowView = vc.view

    SnapshotTesting.diffTool = "ksdiff"
//    isRecording = true
  }

  func testPlayToPause() {
    let sampler = AnimationSampler()
    let button = PlayButton()
    button.setMode(.play, animated: false)
    windowView.addSubview(button)

    button.setMode(.pause, animated: true)

    let expectation = sampler.snapshotAnimation(for: button.layer, numberOfFrames: 20)
    wait(for: [expectation], timeout: 10.0)
  }

  func testPlayToStop() {
    let sampler = AnimationSampler()
    let button = PlayButton()
    button.setMode(.play, animated: false)
    windowView.addSubview(button)

    button.setMode(.stop, animated: true)

    let expectation = sampler.snapshotAnimation(for: button.layer, numberOfFrames: 20)
    wait(for: [expectation], timeout: 10.0)
  }

  func testPlayToBuffering() {
    let sampler = AnimationSampler()
    let button = PlayButton()
    button.setMode(.play, animated: false)
    windowView.addSubview(button)

    button.setMode(.buffering, animated: true)

    let expectation = sampler.snapshotAnimation(for: button.layer, numberOfFrames: 20)
    wait(for: [expectation], timeout: 10.0)
  }

  func testBuffering() {
    let sampler = AnimationSampler()
    let button = PlayButton()
    button.setMode(.play, animated: false)
    windowView.addSubview(button)

    button.setMode(.buffering, animated: false)

    let expectation = sampler.snapshotAnimation(for: button.layer, numberOfFrames: 30)
    wait(for: [expectation], timeout: 10.0)
  }

  func testStopToPause() {
    let sampler = AnimationSampler()
    let button = PlayButton()
    button.setMode(.stop, animated: false)
    windowView.addSubview(button)

    button.setMode(.pause, animated: true)

    let expectation = sampler.snapshotAnimation(for: button.layer, numberOfFrames: 14)
    wait(for: [expectation], timeout: 10.0)
  }

  func testStopToPlay() {
    let sampler = AnimationSampler()
    let button = PlayButton()
    button.setMode(.stop, animated: false)
    windowView.addSubview(button)

    button.setMode(.play, animated: true)

    let expectation = sampler.snapshotAnimation(for: button.layer, numberOfFrames: 20)
    wait(for: [expectation], timeout: 10.0)
  }

  func testPauseToBuffering() {
    let sampler = AnimationSampler()
    let button = PlayButton()
    button.setMode(.pause, animated: false)
    windowView.addSubview(button)

    button.setMode(.buffering, animated: true)

    let expectation = sampler.snapshotAnimation(for: button.layer, numberOfFrames: 20)
    wait(for: [expectation], timeout: 10.0)
  }

  func testPauseToPlay() {
    let sampler = AnimationSampler()
    let button = PlayButton()
    button.setMode(.pause, animated: false)
    windowView.addSubview(button)

    button.setMode(.play, animated: true)

    let expectation = sampler.snapshotAnimation(for: button.layer, numberOfFrames: 20)
    wait(for: [expectation], timeout: 10.0)
  }

  func testStylingColors() {
    let button = PlayButton()
    button.pauseStopBackgroundColor = .systemOrange
    button.pauseStopTintColor = .black
    button.playBufferingBackgroundColor = .systemBlue
    button.playBufferingTintColor = .white

    windowView.addSubview(button)

    CATransaction.setDisableActions(true)

    button.setMode(.play, animated: false)
    assertSnapshot(matching: button, as: .image, named: "play")
    button.setMode(.pause, animated: false)
    assertSnapshot(matching: button, as: .image, named: "pause")
    button.setMode(.buffering, animated: false)
    assertSnapshot(matching: button, as: .image, named: "buffering")
    button.setMode(.stop, animated: false)
    assertSnapshot(matching: button, as: .image, named: "stop")

    CATransaction.setDisableActions(false)
  }

  func testStylingShapes() {
    let button = PlayButton()
    button.pauseStopBackgroundColor = .systemBlue
    button.pauseStopTintColor = .white
    button.playBufferingBackgroundColor = .systemBlue
    button.playBufferingTintColor = .white
    button.triangleCornerRadius = 3.0
    button.squareCornerRadius = 3.0

    windowView.addSubview(button)

    CATransaction.setDisableActions(true)

    button.setMode(.play, animated: false)
    assertSnapshot(matching: button, as: .image, named: "play")
    button.setMode(.pause, animated: false)
    assertSnapshot(matching: button, as: .image, named: "pause")
    button.setMode(.buffering, animated: false)
    assertSnapshot(matching: button, as: .image, named: "buffering")
    button.setMode(.stop, animated: false)
    assertSnapshot(matching: button, as: .image, named: "stop")

    CATransaction.setDisableActions(false)
  }

  // Convenience tests
  func testConvenienceIsStopGetter() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))

    button.setMode(.play, animated: false)
    XCTAssertEqual(button.isStop, false)
    button.setMode(.stop, animated: false)
    XCTAssertEqual(button.isStop, true)
  }

  func testConvenienceIsPlayGetter() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))

    button.setMode(.stop, animated: false)
    XCTAssertEqual(button.isPlay, false)
    button.setMode(.play, animated: false)
    XCTAssertEqual(button.isPlay, true)
  }

  func testConvenienceIsBufferingGetter() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))

    button.setMode(.play, animated: false)
    XCTAssertEqual(button.isBuffering, false)
    button.setMode(.buffering, animated: false)
    XCTAssertEqual(button.isBuffering, true)
  }

  func testConvenienceIsPauseGetter() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))

    button.setMode(.play, animated: false)
    XCTAssertEqual(button.isPause, false)
    button.setMode(.pause, animated: false)
    XCTAssertEqual(button.isPause, true)
  }

  func testSetMode() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))

    button.setMode(.play, animated: false)
    XCTAssertEqual(button.mode, .play)
    button.setMode(.pause, animated: false)
    XCTAssertEqual(button.mode, .pause)
    button.setMode(.buffering, animated: false)
    XCTAssertEqual(button.mode, .buffering)
    button.setMode(.stop, animated: false)
    XCTAssertEqual(button.mode, .stop)
  }

  func testSetStop() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))

    XCTAssertEqual(button.isStop, false)
    button.setStop(true, animated: false)
    XCTAssertEqual(button.isStop, true)
  }

  func testScaleAspectFillWidthGreaterThanHeight() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
    button.backgroundColor = .blue
    button.contentMode = .scaleAspectFill

    windowView.addSubview(button)
    assertSnapshot(matching: button, as: .image)
  }

  func testScaleAspectFillHeightGreaterThanWidth() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 30, height: 60))
    button.backgroundColor = .blue
    button.contentMode = .scaleAspectFill

    windowView.addSubview(button)
    assertSnapshot(matching: button, as: .image)
  }

  func testScaleAspectFitWidthGreaterThanHeight() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
    button.backgroundColor = .blue
    button.contentMode = .scaleAspectFit

    windowView.addSubview(button)
    assertSnapshot(matching: button, as: .image)
  }

  func testScaleAspectFitHeightGreaterThanWidth() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 30, height: 60))
    button.backgroundColor = .blue
    button.contentMode = .scaleAspectFit

    windowView.addSubview(button)
    assertSnapshot(matching: button, as: .image)
  }

  func testScaleToFillWidthGreaterThanHeight() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
    button.backgroundColor = .blue
    button.contentMode = .scaleToFill

    windowView.addSubview(button)
    assertSnapshot(matching: button, as: .image)
  }

  func testScaleToFillHeightGreaterThanWidth() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 30, height: 60))
    button.backgroundColor = .blue
    button.contentMode = .scaleToFill

    windowView.addSubview(button)
    assertSnapshot(matching: button, as: .image)
  }

  func testTriangleOpticalAlignmentZeroCornerRadius() {
    let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 176, height: 176))
		button.triangleCornerRadius = 0.0
    button.playBufferingBackgroundColor = .systemBlue
    button.playBufferingTintColor = .white

    let circle = CircleView(frame: CGRect(origin: .zero, size: CGSize(width: 102, height: 102)))
    button.addSubview(circle)
    circle.center = button.center

    windowView.addSubview(button)

    assertSnapshot(matching: button, as: .image, named: "triangle")
  }

	func testTriangleOpticalAlignmentDefaultCornerRadius() {
		let button = PlayButton(frame: CGRect(x: 0, y: 0, width: 176, height: 176))
		button.playBufferingBackgroundColor = .systemBlue
		button.playBufferingTintColor = .white

		let circle = CircleView(frame: CGRect(origin: .zero, size: CGSize(width: 92, height: 92)))
		button.addSubview(circle)
		circle.center = button.center

		windowView.addSubview(button)

		assertSnapshot(matching: button, as: .image, named: "triangle")
	}
}

private enum CompletionCondition {
  case numberOfFrames(Int)
  case duration(CFTimeInterval)
}

@available(iOS 13.0.0, *)
private final class AnimationSampler: NSObject {
  private var displayLink: CADisplayLink?
  private var images = [UIImage]()
  private var targetLayer: CALayer?
  private var completionCondition: CompletionCondition!
  private var timeRunning: CFTimeInterval = 0
  private var completionHandler: (([UIImage]) -> Void)?

  private func setup() {
    if displayLink == nil {
      displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
      displayLink?.preferredFramesPerSecond = 30
      displayLink?.add(to: RunLoop.main, forMode: .common)
    }

    images.removeAll()
    timeRunning = 0
  }

  @objc private func tick(_ displayLink: CADisplayLink) {
    timeRunning += displayLink.targetTimestamp - displayLink.timestamp

    guard let frame = targetLayer?.takeSnapshot() else {
      return
    }

    images.append(frame)

    switch completionCondition {
    case let .numberOfFrames(frames) where images.count == frames:
      complete()
    case let .duration(duration) where timeRunning >= duration:
      complete()
    default:
      break
    }
  }

  func snapshotAnimation(for layer: CALayer, numberOfFrames: Int, testName: String = #function) -> XCTestExpectation {
    let expectation = XCTestExpectation(description: testName)

    recordAnimation(for: layer, numberOfFrames: numberOfFrames) { frames in
      XCTAssertEqual(frames.count, numberOfFrames)

      for (index, frame) in frames.enumerated() {
        assertSnapshot(matching: frame, as: .image(precision: 0.85, scale: nil), named: "\(index)", testName: testName)
      }

      expectation.fulfill()
    }

    return expectation
  }

  func recordAnimation(for layer: CALayer, numberOfFrames: Int, completion: @escaping (([UIImage]) -> Void)) {
    completionHandler = completion
    targetLayer = layer
    completionCondition = .numberOfFrames(numberOfFrames)
    setup()
  }

  func recordAnimation(for layer: CALayer, duration: CFTimeInterval, completion: @escaping (([UIImage]) -> Void)) {
    completionHandler = completion
    targetLayer = layer
    completionCondition = .duration(duration)
    setup()
  }

  private func complete() {
    DispatchQueue.main.async { [unowned self] in
      self.completionHandler?(self.images)
      self.completionHandler = nil
    }
  }

  deinit {
    displayLink?.invalidate()
    displayLink = nil
  }
}

extension CALayer {
  func takeSnapshot() -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    (presentation() ?? self).render(in: context)
    let rasterizedView = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return rasterizedView
  }
}

class CircleView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else {return}

    context.setLineWidth(1)
    context.setStrokeColor(UIColor.green.cgColor)
    context.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
  }
}
