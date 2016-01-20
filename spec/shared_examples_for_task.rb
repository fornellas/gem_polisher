require 'gem_polisher'

RSpec.shared_examples :task  do
  let(:gem_polisher) { double('gem_polisher') }
  subject { described_class.new(gem_polisher) }
  it { is_expected.to have_attributes(gem_polisher: gem_polisher) }
  it 'delegates #gem_info to #gem_polisher' do
    expect(gem_polisher).to receive(:gem_info)
    subject.gem_info
  end
  it 'includes Rake::DSL' do
    expect(described_class.ancestors).to include(Rake::DSL)
  end
end
