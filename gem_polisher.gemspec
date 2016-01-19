require_relative 'lib/gem_polisher/version'

Gem::Specification.new do |s|
  s.name             = 'gem_polisher'
  s.version          = GemPolisher::VERSION
  s.summary          = 'This Gem provides Rake tasks to assist Ruby Gem development workflow.'
  s.description      = 'This Gem provides Rake tasks to assist Ruby Gem development workflow.'
  s.email            = 'fabio.ornellas@gmail.com'
  s.homepage         = 'https://github.com/fornellas/gem_polisher'
  s.authors          = ['Fabio Pugliese Ornellas']
  s.files            = Dir.glob('lib/**/*').keep_if{|p| not File.directory? p}
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options     = %w{--main README.md lib/ README.md}
  s.add_runtime_dependency 'gli', '~>2.13', '>=2.13.4'
  s.add_development_dependency 'rspec', '~>3.4'
  s.add_development_dependency 'simplecov', '~>0.11', '>=0.11.1'
end
