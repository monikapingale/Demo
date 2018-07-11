require 'date'
Gem::Specification.new do |gem|
  gem.name        = 'enziEncryptor'
  gem.version     = '0.1.0'
  gem.date        = '2018-06-20'
  gem.summary     = "A simple wrapper for the standard ruby encryption library"
  gem.description = "This gem is use for encryption and decryption of key"
  gem.authors     = ["Kishor Shinde"]
  gem.email       = 'kishor.shinde@enzigma.in'
  gem.files       = ["lib/enziEncryptor.rb"]
  gem.homepage    = 'https://localhost/'
  gem.license     = 'MIT'
  gem.add_development_dependency 'encryptor', '~> 3.0.0'
  gem.post_install_message  = "\n'Welcome to EnziEncryptor'\n"
end