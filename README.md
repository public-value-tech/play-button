# PlayButton

[![build](https://github.com/public-value-tech/play-button/actions/workflows/tests.yml/badge.svg)](https://github.com/public-value-tech/play-button/actions/workflows/tests.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpublic-value-tech%2Fplay-button%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/public-value-tech/play-button)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpublic-value-tech%2Fplay-button%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/public-value-tech/play-button)

A button that can render four different playback related modes and animate between them.

![Different play button appearances](.github/play-button-overview.png)

### Installation (Swift Package Manager)

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding PlayButton as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
  .package(url: "https://github.com/public-value-tech/play-button.git", .branch("main"))
]
```

### Usage

```swift
import PlayButton

let playButton = PlayButton() // defaults to CGSize(width: 44, height: 44)
playButton.playBufferingBackgroundColor = .systemBlue
playButton.pauseStopBackgroundColor = .systemBlue
playButton.playBufferingTintColor = .white
playButon.pauseStopTintColor = .white

// Animate the mode update
playButton.setMode(.stop, animated: true)

// iOS / macCatalyst 
playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside))

// tvOS
playButton.addTarget(self, action: #selector(playButtonTapped), for: .primaryActionTriggered)
```

<p align="center">
  <img src="./.github/iOS.gif" width="80%">
</p>
<p align="center">
  <img src="./.github/tvOS.gif" width="80%">
</p> 

### Documentation

Check out the [documentation](https://swiftpackageindex.com/public-value-tech/play-button/documentation/playbutton) or just compile it yourself when you add the package to your projects. 

### Tests

The tests mostly consist of snapshot tests. We use a `CADisplayLink` to sample some frames from the animation and diff them against reference snapshots. Since there is some expected deviation we add some tolerance to the tests.

### How it all started

You may wonder what's so special about this play button. In [this article](https://medium.com/br-next/open-sourcing-our-br-radio-playbutton-5f0b14bb7e01) we describe the difficulties we have faced implementing an interruptible and reversible animation in Core Animation.
