class GemPolisher
  # gem:release task
  class ReleaseTask < Task

    extend Forwardable

    def_delegators :gem_polisher,
      :agita,
      :gem_info,
      :gem_publish_command

    def create_task
      namespace :gem do
        desc 'Update bundle, run tests, increment version, build and publish Gem; type can be major, minor or patch.'
        task :release, [:type] do |t, args|
          type = args[:type]
          git_ensure_master_updated_clean
          bundle_update
          Rake::Task[:test].invoke
          inc_version(type)
          gem_build
          gem_publish
        end
      end
    end

    private

    # :section: Steps

    # Make sure we are at master, updated and clean.
    def git_ensure_master_updated_clean
      agita.ensure_master_updated_clean
    end

    # bundle update
    def bundle_update
      run 'bundle update'
      if agita.commit('Updated Bundle', 'Gemfile.lock')
        unless File.basename($PROGRAM_NAME) == 'rake'
          raise RuntimeError.new("Not executed by rake executable!")
        end
        exec 'bundle', *['exec', 'rake', *ARGV]
      end
    end

    # Increment Gem version
    def inc_version type
      new_version = gem_info.inc_version!(type)
      # This loop shouldn't be needed, but test fails without it. Bundler bug?
      2.times{ run("bundle install") }
      agita.commit("Increased #{type} version.", 'Gemfile.lock', gem_info.gem_version_rb)
      agita.tag("v#{new_version.to_s}", "New #{type} version.")
    end

    # Build .gem
    def gem_build
      run("gem build #{gem_info.gem_name}.gemspec")
    end

    # Path to .gem
    def gem_path
      "#{gem_info.gem_name}-#{gem_info.semantic_version}.gem"
    end

    # Publishes .gem with gem_publish_command
    def gem_publish
      run("#{gem_publish_command} #{Shellwords.escape(gem_path)}")
    end

    # :section: Helpers

    def run command
      output = `#{command}`
      raise "#{command} returned non-zero status:\n#{output}" unless $?.exitstatus == 0
      output
    end

  end
end
