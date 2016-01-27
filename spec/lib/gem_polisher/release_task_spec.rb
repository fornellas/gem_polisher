require 'gem_polisher'
require 'shared_examples_for_task'
require 'fileutils'
require 'shellwords'
require 'shared_context_for_test_gem'

RSpec.describe GemPolisher::ReleaseTask  do
  include_context :test_gem
  include_examples :task_examples
  context 'gem:release[type]' do
    context 'workflow' do
      let(:type) { 'minor' }
      # Silent #step
      around(:example) do |example|
        original_stdout = STDOUT.clone
        STDOUT.reopen(File.open('/dev/null', 'w'))
        begin
          example.call
        ensure
          STDOUT.reopen(original_stdout)
        end
      end
      it 'does correct workflow' do
        expect(subject).to receive(:git_ensure_master_updated_clean).ordered
        expect(subject).to receive(:bundle_update).ordered
        expect(Rake::Task[:test]).to receive(:invoke).ordered
        expect(subject).to receive(:inc_version).with(type).ordered
        expect(subject).to receive(:gem_build).ordered
        expect(subject).to receive(:gem_publish).ordered
        Rake::Task['gem:release'].invoke(type)
      end
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
        before(:example) do
          allow(subject).to receive(:exec)
          allow(subject).to receive(:run)
        end
        it 'calls bundle update' do
          expect(subject).to receive(:run).with('bundle update')
          subject.send(:bundle_update)
        end
        context 'Gemfile.lock updated' do
          def mock_program_name path
            original_program_name = $PROGRAM_NAME
            begin
              $PROGRAM_NAME = path
              yield
            ensure
              $PROGRAM_NAME = original_program_name
            end
          end
          around(:example) do |example|
            mock_program_name('/usr/bin/rake') do
              example.call
            end
          end
          before(:example) do
            expect(subject).to receive(:run).with('bundle update') do
              File.open('Gemfile.lock', 'w'){|io| io.write('new content')}
            end
          end
          context 'Not started via rake binary' do
            around(:example) do |example|
              mock_program_name('/usr/bin/not_rake') do
                example.call
              end
            end
            it 'raises' do
              expect do
                subject.send(:bundle_update)
              end.to raise_error(RuntimeError)
            end
          end
          it 'commits it' do
            expect(run('git status --porcelain Gemfile.lock')).to be_empty
            subject.send(:bundle_update)
          end
          context 'reloading bundle' do
            let(:probe_argv) { ['arg1', 'arg2'] }
            before(:example) do
              stub_const('ARGV', probe_argv)
            end
            it 'calls Kernel#exec with same arguments' do
              expect(subject).to receive(:exec).with('bundle', 'exec', 'rake', *ARGV)
              subject.send(:bundle_update)
            end
          end
        end
      end
      context '#inc_version' do
        let(:type) { :minor }
        let(:new_version) { gem_version_next_minor_str }
        # Clean up environment to allow bundler to run
        before(:example) do
          allow_any_instance_of(described_class)
            .to receive(:run)
            .and_wrap_original do |m, *args, &block|
              keys_to_remove = ENV.keys.grep(/^BUNDLE_/)
              keys_to_remove << 'RUBYOPT'
              keys_to_remove << 'RUBYLIB'
              old_values = {}
              keys_to_remove.each do |key|
                old_values[key] = ENV[key]
                ENV.delete(key)
              end
              m.call(*args, &block)
              old_values.keys.each do |key|
                ENV[key] = old_values[key]
              end
            end
        end
        # Semantic::Version#inc_version! does not work with String
        it 'calls Semantic::Version#inc_version! with a Symbol' do
          expect_any_instance_of(Semantic::Version)
            .to receive(:increment!)
            .with(kind_of(Symbol))
            .and_call_original
          subject.send(:inc_version, type)
        end
        it 'increments version at version.rb' do
          expect do
            subject.send(:inc_version, type)
          end.to change {
            File.open(version_rb).read.include?(new_version)
          }.from(false).to(true)
        end
        it 'increments version at Gemfile.lock' do
          expect do
            subject.send(:inc_version, type)
          end.to change {
            File.open('Gemfile.lock').read.include?(new_version)
          }.from(false).to(true)
        end
        it 'commits Gemfile.lock and version.rb' do
          subject.send(:inc_version, type)
          latest_diff = `git diff --word-diff=porcelain HEAD^`
          expect(latest_diff).to match(/^diff .+\/Gemfile.lock$/)
          expect(latest_diff).to match(/^diff .+\/version\.rb$/)
          latest_message = `git log -1`
          expect(latest_message).to include("Increased #{type} version.")
        end
        it 'creates version tag' do
          expect do
            subject.send(:inc_version, type)
          end.to change{
            `git tag`.match(/^v#{Regexp.escape(new_version)}$/)
          }.from(be_falsey).to(be_truthy)
        end
      end
      context '#gem_build' do
        it 'builds .gem' do
          expect do
            subject.send(:gem_build)
          end.to change{File.exist?("#{gem_name}-#{gem_version_str}.gem")}
            .from(be_falsey).to(be_truthy)
        end
      end
      context '#gem_publish' do
        let(:gem_publish_command) { subject.gem_publish_command }
        let(:gem_path) { "#{gem_name}-#{gem_version_str}.gem" }
        before(:example) do
          FileUtils.touch(gem_path)
        end
        it 'calls gem_publish_command and deletes .gem' do
          expect(subject).to receive(:run)
            .with("#{gem_publish_command} #{gem_path}")
          expect{subject.send(:gem_publish)}
            .to change{File.exist?(gem_path)}
            .from(be_truthy)
            .to(be_falsey)
        end
      end
    end
  end
end
