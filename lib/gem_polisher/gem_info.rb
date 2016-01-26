require 'semantic'

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

    # Returns value of Gem's main constant.
    def gem_main_constant
      gem_specification # avoid NameError if not loaded.
      Object.const_get(gem_main_constant_s)
    end

    # Returns Gem::Specification object.
    def gem_specification
      # Avoids warning over redefined VERSION constant
      version_const_str = '::' + gem_main_constant_s + "::VERSION"
      if Object.const_defined?(version_const_str)
        Object.const_get(gem_main_constant_s).send(:remove_const, :VERSION)
      end
      # Allow #gem_version_rb to be reloaded after changes
      $LOADED_FEATURES.delete_if{|f| f == File.absolute_path(gem_version_rb)}
      eval(File.open(gemspec_path, 'r').read, nil, gemspec_path)
    end

    # Returns a Semantic::Version instance
    def semantic_version
      Semantic::Version.new(gem_specification.version.to_s)
    end

    # Path to Gem's version.rb
    def gem_version_rb
      "lib/#{gem_name}/version.rb"
    end

    # Increment version at "lib/#{gem_name}/version.rb".
    def inc_version! type
      new_version = semantic_version.increment!(type)
      const_class = gem_main_constant.class.to_s.downcase
      const_name = gem_main_constant
      ancestor_classes = gem_main_constant.ancestors.keep_if{|a| a.class == Class}
      parent_class = ( parent = ancestor_classes[1] ) == Object ? nil : parent
      File.open(gem_version_rb, 'w') do |io|
        io.puts "#{const_class} #{const_name}#{" < #{parent_class}" if parent_class}"
        io.puts "  VERSION = '#{new_version.to_s}'"
        io.puts "end"
      end
      new_version
    end
  end
end
