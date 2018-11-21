Pod::Spec.new do |s|
    s.name = 'MiniNe'
    s.version = '1.2.1'
    s.license = 'MIT'
    s.summary = 'Miniature networking framework'
    s.homepage = 'https://github.com/kevcodex/MiniNe'
    s.authors = { 'Kevin Chen' => 'kevchen2@gmail.com' }
    s.source = { :git => 'https://github.com/kevcodex/MiniNe.git', :tag => s.version }
  
    s.ios.deployment_target = '10.0'
    s.osx.deployment_target = '10.10'
    s.tvos.deployment_target = '10.0'
    s.watchos.deployment_target = '3.0'
  
    s.source_files = 'Source/*.swift'
  end