RSpec.describe 'bin/gem_polisher' do
  context 'new' do
    it 'creates gem_name directory'
    shared_examples :rb_files do
      it 'creates gem_name/lib/gem_name/version.rb'
      it 'creates gem_name/lib/gem_name.rb'
      it 'creates gem_name/gem_name.gemspec'
    end
    context 'class main constant' do
      include_examples :rb_files
    end
    context 'child class main constant' do
      include_examples :rb_files
    end
    context 'module main constant' do
      include_examples :rb_files
    end
    it 'creates gem_name/Rakefile'
  end
end
