require 'fileutils'

module Murmurs
  module Git
    def git_hooks_dir(git_repo_dir)
      hooks = File.join(git_repo_dir, 'hooks')
      if File.exists?(hooks)
        hooks
      else
        hooks = File.join(git_repo_dir, '.git', 'hooks')
        if File.exists?(hooks)
          hooks
        else
          raise "Could not find \"hooks\" dir or \".git/hooks\" dir in #{git_repo_dir}"
        end
      end
    end

    def install_git_hook(git_dir, script)
      hooks = git_hooks_dir(git_dir)
      hook = File.join(hooks, 'post-receive')
      if File.exists?(hook)
        raise HookExistsError, "There is #{hook} file existing, please backup / remove it."
      end

      File.open(hook, 'w') do |f|
        f.write <<-BASH
#!/usr/bin/env bash

mingle_murmurs_url=$(git config hooks.minglemurmursurl)
mingle_access_key_id=$(git config hooks.mingleaccesskeyid)
mingle_access_secret_key=$(git config hooks.mingleaccesssecretkey)

echo "$(cat)" | #{script.inspect} -g -b master -m "$mingle_murmurs_url" -k "$mingle_access_key_id" -s "$mingle_access_secret_key"
BASH
      end
      FileUtils.chmod('+x', hook)
      hook
    end

    # input: git post receive stdin string
    # branch: git branch
    def git_commits(input, branch)
      data = input.split("\n").map do |l|
        l.split
      end.find do |l|
        l[2] =~ /\Arefs\/heads\/#{branch}\z/
      end

      return if data.nil?

      null_rev = '0' * 40
      from_rev, to_rev, _ = data
      if to_rev == null_rev # delete branch
        "Someone deleted branch #{branch}."
      else
        repo_name = File.basename(Dir.getwd)
        revs = if from_rev == null_rev  # new branch
                 to_rev
               else
                 "#{from_rev}..#{to_rev}"
               end
        `git rev-list #{revs}`.split("\n").map do |rev|
          `git log -n 1 #{rev}`
        end.reverse.map do |msg|
          lines = msg.split("\n")
          commit = lines[0][8..20]
          author = lines[1]
          time = lines[2]
          msg = lines[3..-1]
          <<-MURMUR
#{author}

#{msg.join("\n").strip}

commit #rev-#{commit} (#{repo_name})
#{time}
MURMUR
        end
      end
    end
  end
end
