RSpec.describe GemPolisher do
  context '#initialize' do
    context 'attributes' do
      it 'accepts custom publish command'
      it 'accepts custom Gem constant'
    end
    context 'Rake tasks creation' do
      it 'creates Rake tasks'
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
