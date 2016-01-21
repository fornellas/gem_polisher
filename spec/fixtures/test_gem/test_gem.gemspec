require_relative 'lib/test_gem/version'

Gem::Specification.new do |s|
  s.name        = 'test_gem'
  s.version     = TestGem::VERSION
  s.summary     = 'Project summary'
  s.description = 'Project description'
  s.authors     = ['John Doe']
  s.email       = 'john.doe@example.com'
  s.homepage    = 'http://example.com/'
  s.files       = Dir.glob('lib/**/*').keep_if{|p| not File.directory? p}
  s.license     = 'Proprietary'
end
