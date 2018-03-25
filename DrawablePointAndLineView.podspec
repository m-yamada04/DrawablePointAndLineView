#
#  Be sure to run `pod spec lint DrawablePointAndLineView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "DrawablePointAndLineView"
  s.version      = "0.0.6"
  s.summary      = "Drawable point and line while swiching the drawing mode."

  s.homepage     = "https://github.com/m-yamada04/DrawablePointAndLineView"

  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }

  s.author             = { "Maika Yamada" => "m.yamada1992@gmail.com" }

  s.platform     = :ios
  s.platform     = :ios, "11.0"

  s.source       = { :git => "https://github.com/m-yamada04/DrawablePointAndLineView.git", :tag => "#{s.version}" }

  s.source_files  = "DrawablePointAndLineView", "DrawablePointAndLineView/**/*.{h,m}"

  s.requires_arc = true

end

