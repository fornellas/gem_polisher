require 'gem_polisher'
require 'shared_examples_for_task'

RSpec.describe GemPolisher::ReleaseTask  do
  include_examples :task
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
