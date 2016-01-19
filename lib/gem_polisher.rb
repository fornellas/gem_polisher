require 'rake'

class GemPolisher

  include Rake::DSL

  # String representing Gem's main constant.
  attr_reader :gem_main_constant_s
  # Command used to publish Gem.
  attr_reader :gem_publish_command

  # This should be called from within Rakefile. It will create necessary Rake tasks.
  # Optionally, a Hash can be passed with:
  # +:gem_main_constant_s+:: By default, conventions documented at http://guides.rubygems.org/name-your-gem/ are followed to extract Gem's main constant name, but with strict camel case (eg: Rdoc no RDoc). Use this option case your gem does not follow strict camel case. Eg: for Gem named +net-http-persistent+, use +"Net::HTTP::Persistent"+ here.
  # +:gem_publish_command+:: Command to use to publish your gem (eg. "gem inabox"). Default: "gem push".
  def initialize opts={}
    unless ENV["BUNDLE_GEMFILE"]
      raise RuntimeError.new("#{self.class.to_s} should not be called outside Bundler environment. Try calling rake with 'bundle exec rake'")
    end
    @gem_main_constant_s = opts.fetch(:gem_main_constant_s) do
      default_gem_main_constant_s
    end
    @gem_publish_command = opts.fetch(:gem_publish_command) { 'gem push' }
    define_rake_tasks
  end

  def gemspec_path
    Dir.glob('*.gemspec').first
  end

  # Returns Gem name from #gemspec_path file.
  def gem_name
    gemspec_path.gsub(/\.gemspec$/, '')
  end

  # Argument to be used for #require for the gem.
  def gem_require
    gem_name.downcase.gsub(/-/, '/')
  end

  # Returns String with name of Gem's main constant, calculated from #gem_name, following conventions at: http://guides.rubygems.org/name-your-gem/
  def default_gem_main_constant_s
    const = gem_name
      .capitalize
      .split('_')
      .map{|n| n.capitalize}
      .join('')
    if const.match(/-/)
      const
        .split('-')
        .map do |n|
           n[0].capitalize +
            n[1, n.length]
         end
        .join('::')
    else
      const
    end
  end

  # Defire Rake tasks
  def define_rake_tasks
    namespace :gem do
      desc 'Update bundle, run tests, increment version, build and publish Gem; type can be major, minor or patch.'
      task :release, [:type] => [:test] do |t, args|
        raise 'TODO'
      end
    end
  end

end
