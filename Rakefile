require 'gem_polisher'

gem_name = 'gem_polisher'
gemspec_path = "#{gem_name}.gemspec"
gem_specification = eval(File.open(gemspec_path, 'r').read, nil, gemspec_path)

desc "Build RDoc documentation"
task :rdoc do
  sh 'rm -rf doc/'
  sh [
    'bundle exec rdoc',
    *gem_specification.rdoc_options.map{|p| Shellwords.escape(p)}
  ].join(' ')
end

desc "Run RSpec"
task :rspec do
  sh 'bundle exec rspec'
end

task test: [:rspec]

GemPolisher.new
