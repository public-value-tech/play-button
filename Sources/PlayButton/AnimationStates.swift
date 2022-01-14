enum AnimationState: Equatable {
  case playToBar(PlayToBar)
  case pauseToBar(PauseToBar)
  case stopToBar(StopToBar)
  case barToPlay(BarToPlay)
  case barToPause(BarToPause)
  case barToStop(BarToStop)
  case buffering(Buffering)

  enum PlayToBar: Int {
    case playIdle
    case triangleToBar
  }

  enum BarToPause: Int {
    case barRotateVertical
    case barSplit
    case pause
  }
  
  enum PauseToBar: Int {
    case pauseIdle
    case barsMerge
    case barRotateHorizontal
  }

  enum BarToStop: Int {
    case barRotateVertical
    case barExpand
    case stop
  }

  enum StopToBar: Int {
    case stopIdle
    case barShrink
    case barRotateHorizontal
  }

  enum BarToPlay: Int {
    case barToTriangle
    case play
  }

  enum Buffering: Int {
    case buffering
    case toBar
  }
}
