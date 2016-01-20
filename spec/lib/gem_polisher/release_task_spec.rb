require 'gem_polisher'
require 'shared_examples_for_task'
require 'pp'
RSpec.describe GemPolisher::ReleaseTask  do
  include_examples :task_examples
  context 'gem:release[type]' do
    after(:example) do
      Rake::Task['gem:release'].invoke
    end
    it 'does correct workflow' do
      expect(subject).to receive(:ensure_git_clean_master).ordered
      expect(subject).to receive(:bundle_update).ordered
      expect(Rake::Task[:test]).to receive(:invoke).ordered
      expect(subject).to receive(:inc_version).ordered
      expect(subject).to receive(:gem_build).ordered
      expect(subject).to receive(:gem_publish).ordered
    end
  end
  context '#ensure_git_clean_master' do
    it 'works'
  end
  context '#bundle_update' do
    it 'works'
  end
  context '#inc_version' do
    it 'works'
  end
  context '#gem_build' do
    it 'works'
  end
  context '#gem_publish' do
    it 'works'
  end
end
