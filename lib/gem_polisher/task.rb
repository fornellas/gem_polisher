class GemPolisher
  # Parent class that handles Rake tasks creation
  class Task

    include Rake::DSL

    # GemPolisher instance
    attr_reader :gem_polisher

    extend Forwardable

    def_delegators :gem_polisher,
      :gem_info

    # Receive a GemPolisher instance
    def initialize gem_polisher
      @gem_polisher = gem_polisher
    end

  end
end
