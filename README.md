# gem_polisher

[![Gem Version](https://badge.fury.io/rb/gem_polisher.svg)](http://badge.fury.io/rb/gem_polisher)
[![GitHub issues](https://img.shields.io/github/issues/fornellas/gem_polisher.svg)](https://github.com/fornellas/gem_polisher/issues)
[![GitHub license](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://raw.githubusercontent.com/fornellas/gem_polisher/master/LICENSE)
[![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/gem_polisher?type=total)](https://rubygems.org/gems/gem_polisher)

* Home: [https://github.com/fornellas/gem_polisher/](https://github.com/fornellas/gem_polisher/)
* RubyGems.org: [https://rubygems.org/gems/gem_polisher/](https://rubygems.org/gems/gem_polisher/)
* Bugs: [https://github.com/fornellas/gem_polisher/issues](https://github.com/fornellas/gem_polisher/issues)

## Description

This Gem provides Rake tasks to assist Ruby Gem development workflow.

## Utilization

* Create a new Gem (see [http://guides.rubygems.org/make-your-own-gem/](http://guides.rubygems.org/make-your-own-gem/))
  * Follow [already established naming conventions](http://guides.rubygems.org/name-your-gem/).
    * Tip: if you does not use strict camel casing (eg: RDoc and not Rdoc), see <tt>GemPolisher#initialize</tt>'s <tt>gem_main_constant_s</tt> option.
* When creating your <tt>.gemspec</tt> file, point its <tt>version</tt> attribute to an external file. Eg:

```ruby
  require_relative 'lib/my/gem/with_long_name/version'
  Gem::Specification.new do |s|
    s.version = My::Gem::WithLongName::VERSION
    s.add_development_dependency 'rake', '~>10.4' # Change to latest available version!
    s.add_development_dependency 'gem_polisher', '~>0.4' # Change to latest available version!
  end
```

* Create the version file accordingly. Eg:

```ruby
  class My
    class Gem
      class WithLongName
        VERSION = '0.0.0'
      end
    end
  end
```

* Add this to your <tt>Rakefile</tt>:

```ruby
require 'bundler'
Bundler.require

require 'gem_polisher'
GemPolisher.new
```

* Create your <tt>Gemfile</tt> and <tt>Gemfile.lock</tt> using [Bundler](http://bundler.io/).

At this point, you have at your disposal some Rake tasks:

```
$ rake -T
rake gem:release[type]  # Update bundle, run tests, increment version, build and publish Gem; type can be major, minor or patch
rake test               # Run all tests
```

That you can use to generate new releases. The <tt>gem:release[type]</tt> task will:
* Make sure you are at master, with everything commited.
* Update your bundle (<tt>Gemfile.lock</tt>).
* Execute Rake task <tt>test</tt>.
  * Tip: You can define your own test tasks tied to this. Eg:

```ruby
    desc "Run RSpec"
    task :rspec do
      sh 'bundle exec rspec'
    end
    task test: [:rspec]
```

* Build your <tt>.gem</tt>.
* Publish it to https://rubygems.org/.

## Documentation

Documentation is provided via RDoc. The easiest way to read it:

```
gem install --rdoc gem_polisher
gem install bdoc
bdoc
```

You can read it with <tt>ri</tt> also, of course.
