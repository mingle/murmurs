Murmurs
================

Murmurs is a rubygem provides commands to post a murmur message to your Mingle project.
And Git post-receive hook to post murmurs when new commits pushed to Git server.

Ruby 1.9+ is required.

Installation
----------------

    gem install murmurs

A command 'murmurs' will be installed.

Usage
----------------

For posting a murmur on your Mingle project, you need specify:

1. Mingle murmurs URL. It is pointing to your Mingle site and project murmurs api endpoint.
   Example: https://site-name.mingle-api.thoughtworks.com/api/v2/projects/your_project/murmurs.xml
2. Mingle uses HMAC auth access key id and HMAC auth access secret key. Every user can generate one HMAC secret key from his or her profile page under the HMAC Auth Key tab.
   For further information about Mingle user access key id and secret key, please read:
   http://www.thoughtworks.com/products/docs/mingle/current/help/configuring_hmac_authentication.html

Example:

    murmurs -m https://site-name.mingle-api.thoughtworks.com/api/v2/projects/your_project/murmurs.xml -k mingle_access_key_id -s mingle_access_secure_key  "Murmurs Git integration is done. Our git commits will stream to our project's Murmurs."

You can also setup environment variables for the configurations needed as follows:

    export MINGLE_MURMURS_URL=https://site-name.mingle-api.thoughtworks.com/api/v2/projects/your_project/murmurs.xml
    export MINGLE_ACCESS_KEY_ID=mingle_access_key_id
    export MINGLE_ACCESS_SECRET_KEY=mingle_access_secret_key

So that you don't need to specify them when you murmur something:

    murmurs "text"

Type "murmurs -h" for full help.

Integrating Mingle Murmurs with Git
----------------
Murmurs gem can be used to integrate with Git. Use the following instructions to setup your git server so that it murmurs everytime something has been pushed to the server.

On your Git server:

    install ruby 1.9+
    install rubygems if there was no one installed with ruby
    gem install murmurs

murmurs gem should install a new command 'murmurs-git' (In some OS, the script name maybe changed to murmurs-git1.9 for ruby 1.9)

Install the git hook for post-receive:

    murmurs-git <git repository path>

Then, in the git repository, setup the following configs:

    git config hooks.minglemurmursurl "https://your-site.mingle-api.thoughtworks.com/api/v2/projects/your_project/murmurs.xml"
    git config hooks.mingleaccesskeyid <Mingle user access key id>
    git config hooks.mingleaccesssecretkey <Mingle user access secret key>

Note, if murmurs-git script got renamed to murmurs-git1.9 on your OS, another command "murmurs" probably will also be renamed to "murmurs1.9".
The git post-receive hook installed in your <git repository path>/hooks (or <git repository path>/.git/hooks) directory is calling "murmurs" command to post murmur to Mingle, so you need change command "murmurs" in the post-recieve hook to be "murmurs1.9"
