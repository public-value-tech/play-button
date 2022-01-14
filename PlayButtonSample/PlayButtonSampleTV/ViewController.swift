import PlayButton
import UIKit

class ViewController: UIViewController {
  var playButton: PlayButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    playButton = PlayButton()
    playButton.frame.size = CGSize(width: 200, height: 200)
    playButton.addTarget(self, action: #selector(playButtonTapped), for: .primaryActionTriggered)
    playButton.playBufferingBackgroundColor = .white
    playButton.pauseStopTintColor = .white
    playButton.pauseStopBackgroundColor = .systemBlue
    view.addSubview(playButton)
    view.backgroundColor = .lightGray.withAlphaComponent(0.8)

    let otherButton = UIButton(type: .system)
    otherButton.setTitle("Hello tvOS", for: .normal)
    otherButton.sizeToFit()
    otherButton.center = view.center
    otherButton.center.x += 300
    view.addSubview(otherButton)

    playButton.center = view.center
  }

  @objc private func playButtonTapped() {
    switch playButton.mode {
    case .play:
      playButton.setMode(.buffering, animated: true)
    case .buffering:
      playButton.setMode(.stop, animated: true)
    case .stop:
      playButton.setMode(.pause, animated: true)
    case .pause:
      playButton.setMode(.play, animated: true)
    }
  }
}
