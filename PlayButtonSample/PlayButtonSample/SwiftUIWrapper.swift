import PlayButton
import SwiftUI

struct SwiftUIWrapper: View {
  @State var isPlaying = false

  var body: some View {
    VStack(spacing: 15) {
      Toggle(isPlaying ? "Currently Playing" : "Currently Paused", isOn: $isPlaying)

      PlayButtonView(isPlaying: $isPlaying) {
        isPlaying.toggle()
      }
      .playBufferingTintColor(.black)
      .pauseStopTintColor(.black)
      .playBufferingBackgroundColor(.yellow)
      .pauseStopBackgroundColor(.blue)
      .frame(width: 100.0, height: 60.0)
    }
    .padding()
  }
}

/// Sample wrapper for a play button which only exposes an `isPlaying` boolean binding.
struct PlayButtonView: UIViewRepresentable {
  @Binding var isPlaying: Bool
  var tapHandler: () -> Void

  init(isPlaying: Binding<Bool>, _ tapHandler: @escaping () -> Void) {
    _isPlaying = isPlaying
    self.tapHandler = tapHandler
  }

  private var pauseStopBackgroundColor: Color?
  private var playBufferingBackgroundColor: Color?
  private var pauseStopTintColor: Color?
  private var playBufferingTintColor: Color?

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  func makeUIView(context: Context) -> PlayButton {
    let playButton = PlayButton()

    playButton.pauseStopBackgroundColor = pauseStopBackgroundColor.map(UIColor.init) ?? playButton.pauseStopBackgroundColor
    playButton.playBufferingBackgroundColor = playBufferingBackgroundColor.map(UIColor.init) ?? playButton.playBufferingBackgroundColor
    playButton.pauseStopTintColor = pauseStopTintColor.map(UIColor.init) ?? playButton.pauseStopTintColor
    playButton.playBufferingTintColor = playBufferingTintColor.map(UIColor.init) ?? playButton.playBufferingTintColor

    playButton.setMode(isPlaying ? .pause : .play)

    playButton.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)

    return playButton
  }

  func updateUIView(_ playButton: PlayButton, context: Context) {
    context.coordinator.tapHandler = tapHandler

    playButton.pauseStopBackgroundColor = pauseStopBackgroundColor.map(UIColor.init) ?? playButton.pauseStopBackgroundColor
    playButton.playBufferingBackgroundColor = playBufferingBackgroundColor.map(UIColor.init) ?? playButton.playBufferingBackgroundColor
    playButton.pauseStopTintColor = pauseStopTintColor.map(UIColor.init) ?? playButton.pauseStopTintColor
    playButton.playBufferingTintColor = playBufferingTintColor.map(UIColor.init) ?? playButton.playBufferingTintColor

    playButton.setMode(isPlaying ? .pause : .play)
  }
}

extension PlayButtonView {
  class Coordinator {
    var tapHandler: (() -> Void)?

    @objc func buttonTapped() {
      tapHandler?()
    }
  }
}

/// Convenience for styling
extension PlayButtonView {
  func pauseStopBackgroundColor(_ color: Color) -> Self {
    var copy = self
    copy.pauseStopBackgroundColor = color
    return copy
  }

  func playBufferingBackgroundColor(_ color: Color) -> Self {
    var copy = self
    copy.playBufferingBackgroundColor = color
    return copy
  }

  func pauseStopTintColor(_ color: Color) -> Self {
    var copy = self
    copy.pauseStopTintColor = color
    return copy
  }

  func playBufferingTintColor(_ color: Color) -> Self {
    var copy = self
    copy.playBufferingTintColor = color
    return copy
  }
}

struct SwiftUIWrapper_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIWrapper()
  }
}
