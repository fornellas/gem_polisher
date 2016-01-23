RSpec.shared_context :test_gem do
  let(:gem_name) { 'test_gem' }
  let(:gem_main_constant_s) { 'TestGem' }
  let(:gem_main_constant) { Object.const_get(gem_main_constant_s) }
  let(:gem_version_str) { '1.2.3' }
  let(:gem_version_next_major_str) { '2.0.0' }
  let(:gem_version_next_minor_str) { '1.3.0' }
  let(:gem_version_next_patch_str) { '1.2.4' }
  let(:gemspec_path) { "#{gem_name}.gemspec" }
  let(:version_rb) { "lib/#{gem_name}/version.rb" }
  let(:fixtures_path) { File.dirname(__FILE__) + "/fixtures" }
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
  before(:example) do
    if Object.const_defined? gem_main_constant_s
      Object.send(:remove_const, gem_main_constant_s)
    end
  end
  # Set up fake gem
  around(:example) do |example|
    Dir.mktmpdir do |tmpdir|
      inside_path(tmpdir) do
        git_setup_remote(gem_name)
        FileUtils.cp_r(Dir.glob(fixtures_path + "/#{gem_name}/*"), gem_name)
        inside_path(gem_name) do
          run 'git add -A'
          run 'git commit -m dummy --quiet'
          run 'git push --quiet'
          example.call
        end
      end
    end
  end
end
