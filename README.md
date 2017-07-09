# SmartSegmentedControl

[![Version](https://img.shields.io/cocoapods/v/SmartSegmentedControl.svg?style=flat)](http://cocoapods.org/pods/SmartSegmentedControl)
[![License](https://img.shields.io/cocoapods/l/SmartSegmentedControl.svg?style=flat)](http://cocoapods.org/pods/SmartSegmentedControl)
[![Platform](https://img.shields.io/cocoapods/p/SmartSegmentedControl.svg?style=flat)](http://cocoapods.org/pods/SmartSegmentedControl)

This control was created to solve issue, that native UISegmentedControl has. Reffer to [SmartSegmentedControlSwift](https://github.com/svilon/SmartSegmentedControlSwift) for swift version.
UISegmentedControl has issue with apportionsSegmentWidthsByContent setting (adjust segments width proportionally to content). Often, it appears that control bounds are wider, than actual segments width. See screenshot bellow - I put yellow color as layer background.

![UISegmentedControl](https://github.com/svilon/SmartSegmentedControl/blob/master/Screens/UISegmentedControl.png)

With SmartSegmentedControl issue is fixed and same segmented control will look like:

![SmartSegmentedControl](https://github.com/svilon/SmartSegmentedControl/blob/master/Screens/SmartSegmentedControl.png)

Also, SmartSegmentedControl introduces “smart” mode, where, if there is enough room, every segment, that needs to be wider than average width, gets enough room to display content (which is usually less then in proportional mode). If there is no enough room for all content - segments width is distributed proportionally (fixed, of course :) ).

NOTE. SmartSegmentedControl is designed and test only to work with segments with titles, not with images.

## Usage
SmartSegmentedControl provides two new properties to adjust it's behaviour:
* @property (nonatomic, assign) IBInspectable BOOL smartAdjustment;
* @property (nonatomic, assign) IBInspectable BOOL fixNativeProportionalSizing;

As you can see, you can change them in runtime, or configure in IB.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SmartSegmentedControl is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SmartSegmentedControl"
```

## License

SmartSegmentedControl is available under the MIT license. See the LICENSE file for more info.
