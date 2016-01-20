require 'rake'
require_relative 'gem_polisher/gem_info'
require_relative 'gem_polisher/task'
Dir.glob(File.dirname(__FILE__)+ '/gem_polisher/*_task.rb').each do |task|
  require_relative task
end

# Provides Rake tasks to assist Ruby Gem development workflow.
class GemPolisher

  # GemInfo instance
  attr_reader :gem_info

  extend Forwardable

  def_delegators :gem_info,
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
    # For each *Task class...
    self.class.constants.keep_if{|c| c.match(/.Task$/)}.each do |constant|
      # ...initialize it
      self.class.const_get(constant).send(:new, self)
    end
  end

end
