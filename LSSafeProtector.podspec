Pod::Spec.new do |s|
  s.name             = 'LSSafeProtector'
  s.version          = '1.10.0'
  s.summary          = '强大的防止crash框架，支持自释放KVO等19种crash'

#s.description      = '更新了地址被释放又被重新使用导致的误报crash问题，以及野指针问题'
  s.homepage         = 'https://github.com/lsmakethebest/LSSafeProtector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liusong' => 'song@ysui.cn' }
  s.source           = { :git => 'https://github.com/lsmakethebest/LSSafeProtector.git', :tag => s.version.to_s }

s.frameworks   = 'Foundation'
s.platform     = :ios
s.ios.deployment_target = '7.0'
s.requires_arc = true

s.subspec 'Core' do |ss|
    ss.requires_arc = true
    ss.source_files = 'LSSafeProtector/Classes/Core/*'
end

s.subspec 'Foundation' do |ss|
    ss.requires_arc = true
    ss.source_files = 'LSSafeProtector/Classes/Foundation/*'
    ss.dependency 'LSSafeProtector/Core'
  end

s.subspec 'MRC' do |ss|
    ss.requires_arc = false
    ss.source_files = 'LSSafeProtector/Classes/MRC/*'
    ss.dependency 'LSSafeProtector/Foundation'
    ss.dependency 'LSSafeProtector/Core'
 end
  

end
