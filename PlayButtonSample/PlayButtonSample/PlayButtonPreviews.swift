import PlayButton
import SwiftUI
import UIKit

struct PlayButtonWrapper: UIViewRepresentable {
  func makeUIView(context _: Context) -> PlayButton {
    let button = PlayButton()
    button.pauseStopBackgroundColor = .init(white: 0.9, alpha: 1.0)
    button.playBufferingBackgroundColor = .init(white: 0.9, alpha: 1.0)
    button.pauseStopTintColor = .systemBlue
    button.playBufferingTintColor = .systemBlue
    return button
  }
  
  func updateUIView(_: PlayButton, context _: Context) {}
}

struct PlayButtonWrapper2: UIViewRepresentable {
  func makeUIView(context _: Context) -> PlayButton {
    let button = PlayButton()
    button.pauseStopBackgroundColor = .blue
    button.playBufferingBackgroundColor = .lightGray
    button.pauseStopTintColor = .white
    button.playBufferingTintColor = .black
    return button
  }
  
  func updateUIView(_: PlayButton, context _: Context) {}
}

struct PlayButtonWrapper3: UIViewRepresentable {
  func makeUIView(context _: Context) -> PlayButton {
    let button = PlayButton()
    button.pauseStopBackgroundColor = .green
    button.playBufferingBackgroundColor = .green
    button.pauseStopTintColor = .white
    button.playBufferingTintColor = .black
    button.setMode(.stop, animated: false)
    return button
  }
  
  func updateUIView(_: PlayButton, context _: Context) {}
}

struct PlayButtonWrapper_Preview: PreviewProvider {
  static var previews: some View {
    VStack {
      PlayButtonWrapper()
        .frame(width: 44.0, height: 44.0)
      PlayButtonWrapper2()
        .frame(width: 44.0, height: 44.0)
      PlayButtonWrapper()
        .frame(width: 22.0, height: 22.0)
      PlayButtonWrapper3()
        .frame(width: 55.0, height: 55.0)
      PlayButtonWrapper3()
        .frame(width: 100.0, height: 100.0)
    }
  }
}
