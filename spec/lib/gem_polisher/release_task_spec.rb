require 'gem_polisher'
require 'shared_examples_for_task'
require 'fileutils'

RSpec.describe GemPolisher::ReleaseTask  do
  let(:gem_name) { 'example_gem' }
  let(:gemspec_path) { "#{gem_name}.gemspec" }
  # Set up fake gem
  around(:example) do |example|
    old_dir = Dir.pwd
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir)
      FileUtils.touch(gemspec_path)
      example.call
    end
    Dir.chdir(old_dir)
  end
  include_examples :task_examples
  context 'gem:release[type]' do
    it 'does correct workflow' do
      expect(subject).to receive(:git_ensure_master_updated_clean).ordered
      expect(subject).to receive(:bundle_update).ordered
      expect(Rake::Task[:test]).to receive(:invoke).ordered
      expect(subject).to receive(:inc_version).ordered
      expect(subject).to receive(:gem_build).ordered
      expect(subject).to receive(:gem_publish).ordered
      Rake::Task['gem:release'].invoke
    end
    context 'steps' do
      fcontext '#git_ensure_master_updated_clean' do
        context 'correct status' do
          around(:example) do |example|
            example.call
          end
          it 'does not raise' do
            expect do
              subject.send(:git_ensure_master_updated_clean)
            end.not_to raise_error
          end
        end
        context 'incorrect state' do
          it 'raises' do
            expect do
              subject.send(:git_ensure_master_updated_clean)
            end.to raise_error(RuntimeError, /Incorrect Git status/)
          end
        end
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
  end
end
