require 'rake'

RSpec.describe GemPolisher::Task do
  let(:gem_polisher) { instance_double(GemPolisher) }
  subject { described_class.new(gem_polisher) }
  before(:example) do
    allow_any_instance_of(described_class).to receive(:create_task)
  end
  it 'includes Rake::DSL mixin' do
    expect(subject.class.ancestors).to include(Rake::DSL)
  end
  it { is_expected.to have_attributes(gem_polisher: gem_polisher) }
  it 'delegates methods to #gem_polisher' do
    expect(gem_polisher).to receive(:gem_info)
    subject.gem_info
  end
  context '#step' do
    # Silent STDOUT
    around(:example) do |example|
      original_stdout = STDOUT.clone
      STDOUT.reopen(File.open('/dev/null', 'w'))
      begin
        example.call
      ensure
        STDOUT.reopen(original_stdout)
      end
    end
    let(:message) { 'step message' }
    shared_examples :step do
      it 'prints message' do
        expect do
          subject.step(message) {  }
        end.to output(/#{Regexp.escape(message)}/).to_stdout
      end
    end
    context 'on success' do
      include_examples :step
      it 'prints OK' do
        expect do
          subject.step(message) {  }
        end.to output(/OK/).to_stdout
      end
    end
    context 'on failure' do
      include_examples :step
      let(:block_exeption) { RuntimeError.new('Test Exception') }
      it 'prints FAIL' do
        expect do
          subject.step(message) { raise block_exeption } rescue block_exeption
        end.to output(/FAIL/).to_stdout
      end
      it 'raises block exception' do
        expect do
          subject.step(message) { raise block_exeption }
        end.to raise_exception(block_exeption)
      end
    end
  end
end
