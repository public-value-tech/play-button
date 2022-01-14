import Combine
import PlayButton
import UIKit

class UIKitViewController: UIViewController {
  @objc func nextState() {
    switch playButton.mode {
    case .play:
      playButton.setMode(.buffering, animated: true)
    case .buffering:
      playButton.pauseStopTintColor = .white
      playButton.pauseStopBackgroundColor = .systemOrange
      playButton.setMode(.stop, animated: true)
    case .stop:
      playButton.setMode(.pause, animated: true)
    case .pause:
      playButton.setMode(.play, animated: true)
    }
  }
  
  var playButton: PlayButton!
  var cancellables: Set<AnyCancellable> = []
  
  init() {
    super.init(nibName: nil, bundle: nil)
    
    tabBarItem.title = "UIKitCode"
    tabBarItem.image = UIImage(systemName: "2.circle")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    Timer.publish(every: 5.5, on: .main, in: .default)
      .autoconnect()
      .receive(on: DispatchQueue.main)
      .sink { _ in
        self.nextState()
      }
      .store(in: &cancellables)
    
    playButton = PlayButton()
    playButton.frame.size = CGSize(width: 200, height: 200)
    playButton.addTarget(self, action: #selector(nextState), for: .touchUpInside)
    playButton.playBufferingBackgroundColor = .white
    playButton.pauseStopTintColor = .white
    playButton.pauseStopBackgroundColor = .systemBlue
    view.addSubview(playButton)
    view.backgroundColor = .lightGray.withAlphaComponent(0.8)
    
    playButton.center = view.center
  }
}

