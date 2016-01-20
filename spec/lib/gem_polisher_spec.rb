require 'gem_polisher'
require 'rake'
require 'fileutils'

RSpec.describe GemPolisher do
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
      context '#gem_publish_command' do
        let(:attribute) { :gem_publish_command }
        let(:default_value) { 'gem push' }
        let(:initialize_value) { 'gem inabox' }
        include_examples :initialize_attributes
      end
      context 'GemInfo' do
        let(:opts) { {} }
        subject { described_class.new(opts) }
        let(:gem_info) { double('GemInfo') }
        it 'initializes it with same arguments' do
          expect(GemPolisher::GemInfo)
            .to receive(:new)
            .with(opts)
            .once
            .and_return(gem_info)
          expect(subject.instance_variable_get(:@gem_info)).to eq(gem_info)
        end
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
  context '@gem_info delegators' do
    let(:gem_info) { double('GemInfo') }
    before(:example) do
      expect(GemPolisher::GemInfo)
        .to receive(:new)
        .once
        .and_return(gem_info)
    end
    [
      :gemspec_path,
      :gem_name,
      :gem_require,
      :gem_main_constant_s
    ].each do |delegator|
      it "delegates :#{delegator}" do
        expect(gem_info).to receive(delegator).once
        subject.send(delegator)
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
end
