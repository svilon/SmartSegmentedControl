#
# Be sure to run `pod lib lint SmartSegmentedControl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SmartSegmentedControl'
  s.version          = '0.1.2'
  s.summary          = 'UISegmentedControl replacement which provides more accurate segments width management'

  s.description      = <<-DESC
This control was created to solve issue, that native UISegmentedControl has. Reffer to SmartSegmentedControlSwift for swift version.
UISegmentedControl has issue with apportionsSegmentWidthsByContent setting (adjust segments width proportionally to content). Often, it appears that control bounds are wider, than actual segments width.
With SmartSegmentedControl issue is fixed.
Also, SmartSegmentedControl introduces “smart” mode, where, if there is enough room, every segment, that needs to be wider than average width, gets enough room to display content (which is usually less then in proportional mode). If there is no enough room for all content - segments width is distributed proportionally (fixed, of course :) ).

NOTE. SmartSegmentedControl is designed and test only to work with segments with titles, not with images.
DESC

  s.homepage         = 'https://github.com/svilon/SmartSegmentedControl'
  s.screenshots     = 'https://github.com/svilon/SmartSegmentedControl/blob/master/Screens/Example_app.png?raw=true', 'https://github.com/svilon/SmartSegmentedControl/blob/master/Screens/UISegmentedControl.png?raw=true', 'https://github.com/svilon/SmartSegmentedControl/blob/master/Screens/SmartSegmentedControl.png?raw=true'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eugene Shevtsov' => 'i.i.shevtsov@gmail.com' }
  s.source           = { :git => 'https://github.com/svilon/SmartSegmentedControl.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'SmartSegmentedControl/Classes/**/*'
  
  s.frameworks = 'UIKit'
end
