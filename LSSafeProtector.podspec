Pod::Spec.new do |s|
  s.name             = 'LSSafeProtector'
  s.version          = '1.0.1'
  s.summary          = '强大的防止crash框架，支持自释放KVO等11种crash'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/lsmakethebest/LSSafeProtector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liusong' => 'job@ysui.cn' }
  s.source           = { :git => 'https://github.com/lsmakethebest/LSSafeProtector.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'LSSafeProtector/Classes/**/*'

end
