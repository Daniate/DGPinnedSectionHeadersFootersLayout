#
# Be sure to run `pod lib lint DGPinnedSectionHeadersFootersLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DGPinnedSectionHeadersFootersLayout'
  s.version          = '0.0.1'
  s.summary          = 'Get collection view headers that pin to the top and footers that pin to the bottom (similar to UITableView).'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Earlier than iOS 9, use this lib get collection view headers that pin to the top of the screen and collection view footers that pin to the bottom while scrolling (similar to UITableView).'

  s.homepage         = 'https://github.com/Daniate/PinnedSectionHeadersFootersLayout'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniate' => 'daniate@126.com' }
  s.source           = { :git => 'https://github.com/Daniate/DGPinnedSectionHeadersFootersLayout.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '6.0'

  s.source_files = 'DGPinnedSectionHeadersFootersLayout/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DGPinnedSectionHeadersFootersLayout' => ['DGPinnedSectionHeadersFootersLayout/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
