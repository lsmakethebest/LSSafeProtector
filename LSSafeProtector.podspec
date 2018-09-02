Pod::Spec.new do |s|
  s.name             = 'LSSafeProtector'
  s.version          = '1.0.2'
  s.summary          = '强大的防止crash框架，支持自释放KVO等11种crash'

  s.description      = '更新了地址被释放又被重新使用导致的误报crash问题，以及野指针问题'
  s.homepage         = 'https://github.com/lsmakethebest/LSSafeProtector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liusong' => 'job@ysui.cn' }
  s.source           = { :git => 'https://github.com/lsmakethebest/LSSafeProtector.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'LSSafeProtector/Classes/**/*'

end
