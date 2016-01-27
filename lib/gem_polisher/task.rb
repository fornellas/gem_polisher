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
      create_task
    end

    # Creates Rake task (abstract method)
    def create_task
      raise "Not implemented!"
    end

    ANSI_RESET       = "\e[0m"
    ANSI_ATTR_BRIGHT = "\e[1m"
    ANSI_FG_GREEN    = "\e[32m"
    ANSI_FG_RED      = "\e[31m"

    # Log and execute block
    def step name
      print "#{ANSI_RESET}#{ANSI_ATTR_BRIGHT}#{name}...#{ANSI_RESET} "
      begin
        yield
      rescue
        puts "#{ANSI_RESET}#{ANSI_FG_RED}[FAIL]#{ANSI_RESET}"
        raise $!
      else
        puts "#{ANSI_RESET}#{ANSI_FG_GREEN}[OK]#{ANSI_RESET}"
      end
    end

  end
end
