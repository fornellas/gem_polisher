require 'gem_polisher'
require 'shared_examples_for_task'
require 'fileutils'
require 'shellwords'

RSpec.describe GemPolisher::ReleaseTask  do
  let(:gem_name) { 'example_gem' }
  let(:gemspec_path) { "#{gem_name}.gemspec" }
  # Execute command, and return its stdout
  def run command
    output = `#{command}`
    raise "#{command}: non zero exit!" unless $?.exitstatus == 0
    output
  end
  # Execute given block inside given path, ensuring that it chdir to original path
  def inside_path path
    original_pwd = Dir.pwd
    begin
      Dir.chdir(path)
      yield
    ensure
      Dir.chdir(original_pwd)
    end
  end
  # create a fake test Gem at current directory
  def create_fake_gem gem_name
    FileUtils.touch("#{gem_name}.gemspec")
  end
  # Set up a Git at repo_path, pointing to a remote repo at 'remote_repo'
  def git_setup_remote repo_path
    remote_path = 'remote_repo'
    FileUtils.mkdir(remote_path)
    inside_path(remote_path) do
      run 'git init --quiet'
      run 'git config receive.denyCurrentBranch ignore'
    end
    run "git clone --quiet -l #{remote_path}/.git #{Shellwords.escape(repo_path)} 2>/dev/null"
  end
  # Set up fake gem
  around(:example) do |example|
    Dir.mktmpdir do |tmpdir|
      inside_path(tmpdir) do
        git_setup_remote(gem_name)
        inside_path(gem_name) do
          create_fake_gem(gem_name)
          run 'git add -A'
          run 'git commit -m dummy --quiet'
          run 'git push --quiet'
          example.call
        end
      end
    end
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
      context '#git_ensure_master_updated_clean' do
        context 'correct status' do
          it 'does not raise' do
            expect do
              subject.send(:git_ensure_master_updated_clean)
            end.not_to raise_error
          end
        end
        context 'incorrect state' do
          before(:example) do
            FileUtils.touch('untracked')
          end
          it 'raises' do
            expect do
              subject.send(:git_ensure_master_updated_clean)
            end.to raise_error(RuntimeError)
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
