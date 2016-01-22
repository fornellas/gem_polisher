require 'gem_polisher/gem_info'
require 'shared_context_for_test_gem'

RSpec.describe GemPolisher::GemInfo do
  let(:gem_main_constant_s) { 'Net::Http::DigestAuth' }
  before(:example) do
    allow_any_instance_of(described_class)
      .to receive(:default_gem_main_constant_s).and_return(gem_main_constant_s)
  end
  context '#initialize' do
    context '#gem_main_constant_s' do
      let(:attribute) { :gem_main_constant_s }
      let(:default_value) { gem_main_constant_s }
      let(:initialize_value) { 'Net::HTTP::DigestAuth' }
      subject { described_class.new }
      it { is_expected.to have_attributes(attribute => default_value) }
      context 'passed to initialize' do
        subject do
          described_class.new(attribute => initialize_value)
        end
        it { is_expected.to have_attributes(attribute => initialize_value) }
      end
    end
  end
  context '#gemspec_path' do
    let(:gemspec_path) { 'abc.gemspec' }
    around(:example) do |example|
      old_dir = Dir.pwd
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir)
        example.call
      end
      Dir.chdir(old_dir)
    end
    context 'gemspec exists' do
      before(:example) do
        FileUtils.touch(gemspec_path)
      end
      it 'returns gemspec path' do
        expect(subject).to have_attributes(gemspec_path: gemspec_path)
      end
    end
    context 'gemspec does not exist' do
      it 'raises' do
        expect do
          subject.gemspec_path
        end.to raise_error(Errno::ENOENT)
      end
    end
  end
  context '#gem_name' do
    let(:gem_name) { 'gem_name' }
    let(:gemspec_path) { "#{gem_name}.gemspec" }
    before(:example) do
      expect_any_instance_of(described_class)
        .to receive(:gemspec_path)
        .and_return(gemspec_path)
    end
    it 'extracts it from #gemspec_path' do
      expect(subject).to have_attributes(gem_name: gem_name)
    end
  end
  context '#gem_require and #gem_main_constant_s' do
    shared_examples :gem_other_names do |values|
      gem_name, gem_require, gem_main_constant_s = *values
      context "Gem name '#{gem_name}'" do
        before(:example) do
          allow_any_instance_of(described_class)
            .to receive(:gem_name).and_return(gem_name)
          allow_any_instance_of(described_class)
            .to receive(:default_gem_main_constant_s).and_call_original
        end
        it "calculates \#gem_name as '#{gem_require}'" do
          expect(subject).to have_attributes(gem_require: gem_require)
        end
        it "calculates \#gem_main_constant_s as '#{gem_main_constant_s}'" do
          expect(subject).to have_attributes(gem_main_constant_s: gem_main_constant_s)
        end
      end
    end
    [
      # #gem_name              #gem_require            #gem_main_constant_s
      ['ruby_parser',          'ruby_parser',          'RubyParser'],
      ['rdoc-data',            'rdoc/data',            'Rdoc::Data'],
      ['net-http-persistent',  'net/http/persistent',  'Net::Http::Persistent'],
      ['net-http-digest_auth', 'net/http/digest_auth', 'Net::Http::DigestAuth'],
    ].each do |values|
      include_examples :gem_other_names, values
    end
  end
  context '#gem_main_constant' do
    include_context :test_gem
    it 'returns Gem\'s main constant value' do
      expect(subject.gem_main_constant).to eq(gem_main_constant)
    end
  end
  context '#gem_specification' do
    include_context :test_gem
    it 'returns Gem::Specification object' do
      expect(subject.gem_specification).to be_a(Gem::Specification)
    end
    it 'extracts attributes' do
      expect(subject.gem_specification)
        .to have_attributes(
          name: gem_name,
          version: Gem::Version.new(gem_version_str),
        )
    end
  end
  context '#semantic_version' do
    include_context :test_gem
    it 'returns a Semantic::Version' do
      expect(subject.semantic_version).to be_a(Semantic::Version)
    end
    it 'returns correct version' do
      expect(subject.semantic_version.to_s).to eq(gem_version_str)
    end
  end
  fcontext '#inc_version!' do
    shared_examples :main_class do
      include_context :test_gem
      context 'type' do
        let(:version_rb) { "lib/#{gem_name}/version.rb" }
        def fetch_data
          gem_const = Object.const_get(gem_main_constant_s)
          [
            gem_const.class,
            gem_const.ancestors.keep_if{|a| a.class == Class}[1],
          ]
        end
        def remove_gem_main_const
          Object.send(:remove_const, gem_main_constant_s) rescue NameError
        end
        def reload_version
          remove_gem_main_const
          load version_rb
        end
        [:major, :minor, :patch].each do |type|
          it ":#{type}" do
            subject.inc_version!(type)
            # FIXME #gem_specification is not reloading
            expect(subject.semantic_version.to_s).to eq(send(:"gem_version_next_#{type}_str"))
          end
          it 'does not change main constant class and parent' do
            reload_version
            original_class, original_parent = fetch_data
            remove_gem_main_const
            subject.inc_version!(type)
            reload_version
            final_class, final_parent = fetch_data
            expect(final_class).to eq(original_class)
            expect(final_parent).to eq(original_parent)
          end
        end
      end
    end
    context 'module main constant' do
      before(:example) do
        # TODO
      end
      include_examples :main_class
    end
    # context 'class main constant' do
    #   before(:example) do
    #     # TODO
    #   end
    #   include_examples :main_class
    # end
    # context 'inherited class main constant' do
    #   before(:example) do
    #     # TODO
    #   end
    #   include_examples :main_class
    # end
  end
end
