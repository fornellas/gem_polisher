class GemPolisher
  # gem:release task
  class ReleaseTask < Task

    extend Forwardable

    def_delegators :gem_polisher,
      :agita,
      :gem_info

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
      if agita.commit('Gemfile.lock', 'Updated Bundle')
        unless File.basename($PROGRAM_NAME) == 'rake'
          raise RuntimeError.new("Not executed by rake executable!")
        end
        exec 'bundle', *['exec', 'rake', *ARGV]
      end
    end

    # Increment Gem version
    def inc_version type
      new_version = gem_info.inc_version!(type)
      run("bundle install")
      agita.commit('Gemfile.lock', gem_info.gem_version_rb, "Increased #{type} version.")
      agita.tag("v#{new_version.to_s}")
    end

    #
    def gem_build
      ;
    end

    #
    def gem_publish
      ;
    end

    # :section: Helpers

    def run command
      output = `#{command}`
      raise "#{command} returned non-zero status:\n#{output}" unless $?.exitstatus == 0
      output
    end

  end
end
