#
#  Be sure to run `pod spec lint Sombra.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

	spec.name         			= "Sombra"
	spec.version 		 		    = "1.0.1"
	spec.license      			= { :type => "MIT", :file => "LICENSE" }

  spec.platform     			= :ios, "10.0"
  spec.swift_version      = "4.1"
 	spec.framework  			  = "UIKit" 
	spec.source_files  			= "Sombra/**/*.{swift}"

  spec.homepage    		 		= "https://github.com/AnthonyLatsis/Sombra/"
  spec.source       			= { :git => "https://github.com/AnthonyLatsis/Sombra.git", :tag => "#{spec.version}" }
  
  spec.author             = { "Anthony Latsis" => "aqamoss3fan2010@gmail.com" }
  spec.social_media_url   = "https://www.instagram.com/anthonylatsis/"
  
  spec.summary      			= "A light native-style overlay on CALayer to support image projections as shadows"

  spec.requires_arc 			= true

  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
end

