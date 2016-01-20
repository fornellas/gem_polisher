require 'rake'
require_relative 'gem_polisher/gem_info'

# Provides Rake tasks to assist Ruby Gem development workflow.
class GemPolisher

  include Rake::DSL
  extend Forwardable

  def_delegators :@gem_info,
    :gemspec_path,
    :gem_name,
    :gem_require,
    :gem_main_constant_s

  # Command used to publish Gem.
  attr_reader :gem_publish_command

  # This should be called from within Rakefile. It will create necessary Rake tasks.
  # Optionally, a Hash can be passed with:
  # +:gem_publish_command+:: Command to use to publish your gem (eg. "gem inabox"). Default: "gem push".
  # This Hash is also passed to GemPolisher::GemInfo#initialize, so same options are valid here.
  def initialize opts={}
    unless ENV["BUNDLE_GEMFILE"]
      raise RuntimeError.new("#{self.class.to_s} should not be called outside Bundler environment. Try calling rake with 'bundle exec rake'")
    end
    @gem_info = GemInfo.new(opts)
    @gem_publish_command = opts.fetch(:gem_publish_command) { 'gem push' }
    define_rake_tasks
  end

  private

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
