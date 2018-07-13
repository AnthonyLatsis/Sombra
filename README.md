# Sombra

A light native-style retroaction on `CALayer` to support vibrant image projections as shadows.

## Usage

To have an image projection instead of a plane color as a shadow, you use `shadowImage`. The rest is set up the usual way using existing shadow properties.

``` swift
view.layer.shadowOpacity = 0.8
view.layer.shadowOffset = CGSize(width: 0, height: 15)
view.layer.shadowRadius = 30
view.layer.shadowImage = UIImage().cgImage
```
### Considerations

While using an image projection as a shadow, the value of `shadowOpacity` will be cached and the property itself set to zero. This is done for the regular shadow not to appear. Setting the image to `nil` will leave you with a regular shadow, if any (`shadowOpacity > 0`).  
The image projection currently doesn't support animating through shadow properties.

## Requirements

* Xcode 9.4 +
* Swift 4 +
* iOS 11 +

## Installation

Sombra can be integrated using [CocoaPods](https://cocoapods.org/). Specify it in your `Podfile` and run `$ pod install`.

``` ruby
platform :ios, '11.0'
use_frameworks!

target '<Your Target>' do
    pod 'Sombra'
end
```
