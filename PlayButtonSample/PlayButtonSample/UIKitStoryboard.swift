import PlayButton
import UIKit

/// Note: Apparently @IBDesignables still don't work with SPM. If you now how to make it work reach out!
class UIKitStoryboardVC: UIViewController {
  @IBOutlet weak var playButton: PlayButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    tabBarItem.title = "Storyboard"
    tabBarItem.image = UIImage(systemName: "3.circle")
  }
  
  @IBAction func playButtonPressed(_ sender: Any) {
    if playButton.mode == .pause {
      playButton.setMode(.play)
    } else if playButton.mode == .play {
      playButton.setMode(.pause)
    }
  }
}
