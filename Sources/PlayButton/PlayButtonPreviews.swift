import UIKit

#if os(iOS) && canImport(SwiftUI) && DEBUG
  import SwiftUI

  @available(iOS 13.0, *)
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

  @available(iOS 13.0, *)
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

  @available(iOS 13.0, *)
  struct PlayButtonWrapper_Preview: PreviewProvider {
    static var previews: some View {
      VStack {
        PlayButtonWrapper()
          .frame(width: 44.0, height: 44.0)
        PlayButtonWrapper2()
          .frame(width: 44.0, height: 44.0)
      }
    }
  }
#endif
