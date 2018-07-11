Gem::Specification.new do |s|
  s.name        = 'enziUIUtility'
  s.version     = '0.0.1'
  s.date        = '2017-10-17'
  s.summary     = "UI component manupulation gem"
  s.description = "This gem is use to get and set values of UI components"
  s.authors     = ["Amol Darekar"]
  s.email       = 'amol.darekar@enzigma.in'
  s.files       = ["lib/enziUIUtility.rb"]
  s.homepage    = 'http://localhost'
  s.license       = 'MIT'
  s.add_runtime_dependency  'rspec',  '~> 3.6', '>= 3.6.0'
  s.add_runtime_dependency  'selenium-webdriver', '~> 3.4', '>= 3.4.4'
end