require 'gem_polisher'
require 'rake'
require 'fileutils'

RSpec.describe GemPolisher do
  let(:gem_main_constant_s) { 'Net::Http::DigestAuth' }
  before(:example) do
    allow_any_instance_of(described_class)
      .to receive(:default_gem_main_constant_s).and_return(gem_main_constant_s)
  end
  around(:example) do |example|
    old_bundle_gemfile = ENV["BUNDLE_GEMFILE"]
    ENV["BUNDLE_GEMFILE"] = 'Gemfile'
    example.call
    ENV["BUNDLE_GEMFILE"] = old_bundle_gemfile
  end
  context '#initialize' do
    context 'attributes' do
      shared_examples :initialize_attributes do
        subject { described_class.new }
        it { is_expected.to have_attributes(attribute => default_value) }
        context 'passed to initialize' do
          subject do
            described_class.new(attribute => initialize_value)
          end
          it { is_expected.to have_attributes(attribute => initialize_value) }
        end
      end
      context '#gem_main_constant_s' do
        let(:attribute) { :gem_main_constant_s }
        let(:default_value) { gem_main_constant_s }
        let(:initialize_value) { 'Net::HTTP::DigestAuth' }
        include_examples :initialize_attributes
      end
      context '#gem_publish_command' do
        let(:attribute) { :gem_publish_command }
        let(:default_value) { 'gem push' }
        let(:initialize_value) { 'gem inabox' }
        include_examples :initialize_attributes
      end
    end
    context 'Rake tasks creation' do
      before(:example) do
        Rake.application = Rake::Application.new
      end
      it 'creates gem:release[type]' do
        described_class.new
        expect(Rake::Task['gem:release']).to be_a(Rake::Task)
      end
    end
    context 'without bundler environment' do
      around(:example) do |example|
        old_bundle_gemfile = ENV["BUNDLE_GEMFILE"]
        ENV.delete "BUNDLE_GEMFILE"
        example.call
        ENV["BUNDLE_GEMFILE"] = old_bundle_gemfile
      end
      it 'fails' do
        expect do
          described_class.new
        end.to raise_error(RuntimeError)
      end
    end
  end
  context 'Rake tasks' do
    context 'gem:release[type]' do
      xit 'does correct workflow' do
        # ensure_git_clean_master
        # bundle_update
        # Rake::Task[:'test'].invoke
        # inc_version
        # gem_build
        # gem_publish
      end
    end
  end
  describe 'private methods' do
    describe '#gemspec_path' do
      let(:gemspec_path) { 'abc.gemspec' }
      around(:example) do |example|
        old_dir = Dir.pwd
        Dir.mktmpdir do |tmpdir|
          Dir.chdir(tmpdir)
          FileUtils.touch(gemspec_path)
          example.call
        end
        Dir.chdir(old_dir)
      end
      it 'returns gemspec path' do
        expect(subject).to have_attributes(gemspec_path: gemspec_path)
      end
    end
    describe '#gem_name' do
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
    describe '#gem_require and #gem_main_constant_s' do
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
  end
end
