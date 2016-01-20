RSpec.shared_examples :task_examples  do
  let(:gem_polisher) { GemPolisher.new }
  subject { gem_polisher.rake_tasks.select{|t| t.class == described_class}.first }
  before(:example) do
    Rake.application = Rake::Application.new
    subject
  end
  it { is_expected.to have_attributes(gem_polisher: gem_polisher) }
  it 'delegates #gem_info to #gem_polisher' do
    expect(gem_polisher).to receive(:gem_info)
    subject.gem_info
  end
  it 'includes Rake::DSL' do
    expect(described_class.ancestors).to include(Rake::DSL)
  end
end
