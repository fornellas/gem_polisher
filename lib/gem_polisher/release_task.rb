class GemPolisher
  # gem:release task
  class ReleaseTask < Task

    def create_task
      namespace :gem do
        desc 'Update bundle, run tests, increment version, build and publish Gem; type can be major, minor or patch.'
        task :release, [:type] do |t, args|
          ensure_git_clean_master
          bundle_update
          Rake::Task[:test].invoke
          inc_version
          gem_build
          gem_publish
        end
      end
    end

    private

    #
    def ensure_git_clean_master
      ;
    end

    #
    def bundle_update
      ;
    end

    #
    def inc_version
      ;
    end

    #
    def gem_build
      ;
    end

    #
    def gem_publish
      ;
    end

  end
end
