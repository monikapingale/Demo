Gem::Specification.new do |gem|
  gem.name        = 'enziRestforce'
  gem.version     = '0.1.0'
  #gem.date        = '2018-20-4'
  gem.summary     = "UI component manupulation gem"
  gem.description = "This gem is use for CRUD operations in Salesforce"
  gem.authors     = ["Kishor Shinde"]
  gem.email       = 'kishor.shinde@enzigma.in'
  gem.files       = ["lib/enziRestforce.rb"]
  gem.homepage    = 'https://localhost/'
  gem.license     = 'MIT'
  gem.add_development_dependency 'restforce', '~> 0'
end