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
      context '#gem_info' do
        let(:opts) { {} }
        subject { described_class.new(opts) }
        let(:gem_info) { double('GemInfo') }
        it 'initializes it with same arguments' do
          expect(GemPolisher::GemInfo)
            .to receive(:new)
            .with(opts)
            .once
            .and_return(gem_info)
          expect(subject.gem_info).to eq(gem_info)
        end
      end
    end
    context 'Rake tasks creation' do
      before(:example) do
        Rake.application = Rake::Application.new
      end
      subject { described_class.new }
      it 'creates tasks' do
        expect do
          subject
        end.to change{Rake::Task.tasks.empty?}.from(true).to(false)
      end
      it 'sets #rake_tasks' do
        expect(subject.rake_tasks.length).to eq(Rake::Task.tasks.length)
        subject.rake_tasks.each do |task|
          expect(task).to be_a(GemPolisher::Task)
        end
      end
      it 'calls #define_rake_tasks' do
        expect_any_instance_of(described_class).to receive(:define_rake_tasks)
        subject
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
  context '#gem_info delegators' do
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
  context '#define_rake_tasks' do
    it 'initializes all task classes' do
      described_class.constants.keep_if{|c| c.match(/.Task$/)}.each do |constant|
        expect(described_class.const_get(constant)).to receive(:new).with(subject)
      end
      subject.send(:define_rake_tasks)
    end
  end
end
