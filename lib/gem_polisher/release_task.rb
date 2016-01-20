class GemPolisher
  # gem:release task
  class ReleaseTask < Task
    def initialize gem_polisher
      namespace :gem do
        desc 'Update bundle, run tests, increment version, build and publish Gem; type can be major, minor or patch.'
        task :release, [:type] => [:test] do |t, args|
          raise 'TODO'
        end
      end
      super
    end
  end
end
