require 'test/unit'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'murmurs'

class GitInstallTest < Test::Unit::TestCase
  include Murmurs

  def setup
    @test_dir = @git_dir = '/tmp/murmurs_test'
    @hooks = File.join(@test_dir, 'hooks')
    @hook = File.join(@hooks, 'post-receive')
    @murmur_script = File.join(@test_dir, 'murmurs')

    FileUtils.mkdir_p(@test_dir)
    FileUtils.mkdir_p(@hooks)
    FileUtils.touch(@murmur_script)
  end

  def teardown
    FileUtils.rm_rf(@test_dir)
  end

  def test_install_git_hook
    install_git_hook(@git_dir, @murmur_script)
    expected = <<-BASH
#!/usr/bin/env bash

mingle_murmurs_url=$(git config hooks.minglemurmursurl)
mingle_access_key_id=$(git config hooks.mingleaccesskeyid)
mingle_access_secret_key=$(git config hooks.mingleaccesssecretkey)

echo "$(cat)" | #{@murmur_script} -g -b master -m "$mingle_murmurs_url" -k "$mingle_access_key_id" -s "$mingle_access_secret_key"
BASH
    assert_equal expected, File.read(@hook)
  end

  def test_should_not_install_if_hook_existed
    FileUtils.touch @hook
    assert_raise Murmurs::HookExistsError do
      install_git_hook(@git_dir, @murmur_script)
    end
  end

  def test_should_make_git_hook_executable
    install_git_hook(@git_dir, @murmur_script)
    m = File.stat(@hook).mode
    FileUtils.chmod('+x', @hook)
    assert_equal m, File.stat(@hook).mode
  end
end
