require 'gem_polisher'
require 'rake'

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
    describe '#gem_name' do
      it 'extracts it from .gemspec'
    end
    describe '#default_gem_main_constant_s' do
      it 'works in all cases'
    end
  end
end
