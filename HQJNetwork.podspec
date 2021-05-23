#
# Be sure to run `pod lib lint HQJNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HQJNetwork'
  s.version          = '1.0.0'
  s.summary          = 'A short description of HQJNetwork.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 简介
    HCNetwork、HQJNetwork 普通的网络请求
    NetworkIng 带 json 的网络请求
    HQJMD5 MD5 加密
    HQJHttpsTool json 拆分
    AESCrypt AES cbc 解密
                       DESC

  s.homepage         = 'https://github.com/mac/HQJNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mac' => '1219876794@qq.com' }
  s.source           = { :git => 'https://github.com/mac/HQJNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target   = '10.0'
  s.requires_arc            = true
  s.swift_version           = '5.0'

  s.source_files = 'HQJNetwork/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HQJNetwork' => ['HQJNetwork/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire'
  s.dependency 'HandyJSON'
  s.dependency 'CocoaLumberjack/Swift'
  
end
