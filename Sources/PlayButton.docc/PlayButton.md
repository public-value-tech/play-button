# ``PlayButton``

A button that can render four different playback related modes and animate between them.

## Overview

The button can be usefull if you want to add a playful component to your music/audio application. It provides interruptible animations between the different modes to support sudden changes to the player's rate or when buffering occurs. To make the button feel right at home in your app you can tweak some of its appearance. 

![Different appearances of the play button.](play-button-overview.png)

> Note: The simulator shows [glitches](https://stackoverflow.com/questions/65472584/calayer-path-animation-flickers-when-stopping-and-starting-again) during the animations which don't show up on a real device. So make sure to test a real device before submitting an issue. 

## Modes

There are four different modes. To set the mode you use the ``PlayButton/setMode(_:animated:)``. If `animated` is `false` the change occurs without an animation regardless which mode the button is currently in. Setting the mode to ``Mode/buffering`` will always start the buffering animation, the `animated` parameter only determines whether the shape first transforms into the horizontal bar. If you set the mode without providing an `animated` parameter, the transition is animated by default.  

| Mode         | Description                                                         |
| ------------ | ------------------------------------------------------------------- | 
| `buffering`  | The mode indicates a buffering state.                               |
| `pause`      | The mode indicates a button tap triggers pause (two vertical bars). |
| `play`       | The mode indicates a button tap triggers play (triangle).           |
| `stop`       | The mode indicates a button tap triggers stop (square).             |

## Respond to Button Taps

The button uses the Target-Action design pattern to notify your app when the user taps the button. Rather than handle touch events directly, you assign action methods to the button and designate which events trigger calls to your methods. At runtime, the button handles all incoming touch events and calls your methods in response.

You connect a button to your action method using the [addTarget(_:action:for:)](https://developer.apple.com/documentation/uikit/uicontrol/1618259-addtarget) method or by creating a connection in Interface Builder. The signature of an action method takes one of three forms, which are listed in Listing 1. Choose the form that provides the information that you need to respond to the button tap.

```swift
@IBAction func doSomething()
@IBAction func doSomething(sender: UIButton)
@IBAction func doSomething(sender: UIButton, forEvent event: UIEvent)
```

> Tip: The button already handles hover and pointer interactions.

> Note: The button does no custom hit testing so if it's smaller than Apple's recommended touch area touches might not get recognized.

## Sizing

As you can see in the sample project the button can be used in all environments. It's set to be squeezable/stretchable so you don't have to worry about manually setting hugging/compressionResistance priorities. This works, because we use a scaling layer which is set to a size of `44x44` points. Values like ``PlayButton/barCornerRadius`` are normalized to this value so when you create a button that's `88x88` points the default visual corner radius of the bar is actually `6` points (twice the default). 

In UIKit you usually give the button an equal fixed width and height constraint although it can also handle aspect ratios other than `1:1`. The default [contentMode](https://developer.apple.com/documentation/uikit/uiview/1622619-contentmode) is `scaleAspectFit` so the circle will be centered along the longer axis. If - for whatever reason - you wanted a stretched button, set the content mode to `scaleToFill`.

For SwiftUI you can just write a simple wrapper (see sample code) and add a `frame` view modifier with the desired size.

## Styling

You can style the colors and some shape parameters. Make sure you set the properties early in the views lifecycle as changing them later might interfere with the animations.

> Note: Unfortunately, there still seems to be a bug in Xcode handling `@IBDesignable` spm packages which is why interface builder can't really render the component (despite you being able to set colors and corner radii). The publicly adjustable properties are already `@IBInspectable` so once the bug is fixed, the play button will be even nicer to use in IB. 

### Colors

It is possible to set your own colors to the background and the fill colors of the shapes. You do this by setting the
- ``PlayButton/pauseStopBackgroundColor`` to set the background color when the button is in `pause` or `stop` mode
- ``PlayButton/pauseStopTintColor`` to set the fill color of the two vertical bars when the button is in `pause` or the fill color of the square when it's in `stop` mode
- ``PlayButton/playBufferingBackgroundColor`` to set the background color when the button is in `play` or `buffering` mode
- ``PlayButton/playBufferingTintColor`` to set the fill color of the triangle when the button is in `play` or the fill color of the animating horizontal bar/circle when it's in `buffering` mode

Setting the ``PlayButton/pauseStopBackgroundColor`` to orange, the ``PlayButton/pauseStopTintColor`` to black, the ``PlayButton/playBufferingBackgroundColor`` to blue and the ``PlayButton/playBufferingTintColor`` to white will result in the following appearance:

![Result of styling the button with different colors](color-styling.png)

### Shapes

If you want to tweak how the shapes look like, you can change some of their parameters (within a certain threshold). Be aware that the values you set are *normalized* to the default button size of `44x44` points (see: Sizing) so you do not have to think about how big your button will be in the end (or choose different values for different sizes). You can set
- ``PlayButton/PlayButton/barCornerRadius`` to set the corner radius of the bar (default is half the value of the thickness to make a half circle) 
- ``PlayButton/PlayButton/barThickness`` to set the width of the vertical or the height of the horizontal bar
- ``PlayButton/PlayButton/squareCornerRadius`` to set the corner radius of the square (stop)
- ``PlayButton/PlayButton/squareWidth`` to set the width of the square
- ``PlayButton/PlayButton/triangleCornerRadius`` to set the corner radius of the triangle
- ``PlayButton/PlayButton/triangleWidth`` to set the width of the triangle

Setting the ``PlayButton/PlayButton/triangleCornerRadius`` and ``PlayButton/PlayButton/squareCornerRadius`` to `3.0` yields this:

![Result of styling the button with different corner radii](shape-styling.png)

> Note: Depending on the values some animations might look quirky.

## Topics

### Creating Play Buttons
- ``PlayButton/PlayButton/init()``
- ``PlayButton/PlayButton/init(frame:)``
- ``PlayButton/PlayButton/init(coder:)``

### Styling Color

- ``PlayButton/pauseStopBackgroundColor`` 
- ``PlayButton/pauseStopTintColor`` 
- ``PlayButton/playBufferingBackgroundColor`` 
- ``PlayButton/playBufferingTintColor`` 

### Styling Shapes

- ``PlayButton/barCornerRadius`` 
- ``PlayButton/barThickness`` 
- ``PlayButton/squareWidth`` 
- ``PlayButton/triangleCornerRadius`` 
- ``PlayButton/triangleWidth`` 

### Modes
- ``PlayButton/Mode/buffering``
- ``PlayButton/Mode/pause``
- ``PlayButton/Mode/play``
- ``PlayButton/Mode/stop``

### Changing Modes

- ``PlayButton/PlayButton/setMode(_:animated:)``
