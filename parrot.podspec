Pod::Spec.new do |s|
  s.name             = 'parrot-bdd'
  s.version          = '0.1.0'
  s.summary          = 'An anternative implementation of Cucumber in Swift language.'
  s.description      = <<-DESC
    Cucumber is a software tool used by computer programmers for testing other software. It runs automated acceptance tests written in a behavior-driven development (BDD) style. Central to the Cucumber BDD approach is its plain language parser called Gherkin. It allows expected software behaviors to be specified in a logical language that customers can understand.
                       DESC
  s.homepage         = 'https://github.com/enricode/parrot'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'enricode' => 'enrico.franzelli@gmail.com' }
  s.source           = { :git => 'https://github.com/enricode/parrot', :tag => s.version.to_s }
  s.platform = :osx

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Sources/parrot/**/*'

  # s.resource_bundles = {
  #   'parrot' => ['parrot/Assets/*.png']
  # }
end
