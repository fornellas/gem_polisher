class GemPolisher
  # Extracts information from Gem at current directory.
  class GemInfo

    # String representing Gem's main constant.
    attr_reader :gem_main_constant_s

    # Optin Hash can be passed with:
    # +:gem_main_constant_s+:: By default, conventions documented at http://guides.rubygems.org/name-your-gem/ are followed to extract Gem's main constant name, but with strict camel case (eg: Rdoc no RDoc). Use this option case your gem does not follow strict camel case. Eg: for Gem named +net-http-persistent+, use +"Net::HTTP::Persistent"+ here.
    def initialize opts={}
      @gem_main_constant_s = opts.fetch(:gem_main_constant_s) do
        default_gem_main_constant_s
      end
    end

    # Return path to .gemspec file.
    def gemspec_path
      path = Dir.glob('*.gemspec').first
      unless path
        raise Errno::ENOENT.new('*.gemspec not found')
      end
      path
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

    # Returns Gem::Specification object. If #gemfile is nil, returns nil.
    def gem_specification
      eval(File.open(gemspec_path, 'r').read, nil, gemspec_path)
    end
  end
end
