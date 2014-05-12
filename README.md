Murmurs
================

Murmurs is a rubygem for integrating Git with your Mingle project.

Ruby 1.9+ is required. Windows is not supported.

Usage
----------------

What you need from your Mingle site/project:

1. Mingle project murmurs URL. You can get it by substituting your site name and project identifier to the following URL: https://<your-site>.mingle-api.thoughtworks.com/api/v2/projects/<your-project>/murmurs.xml
2. HMAC auth access key id and access secret key to access your Mingle project. You can get it from existing team member, or create a new user and add the user to your project. The HMAC auth access key id and access secret key is generated at "HMAC Auth Key" tab on user's profile page. For further information about Mingle user access key id and secret key, please read: http://www.thoughtworks.com/products/docs/mingle/current/help/configuring_hmac_authentication.html

On your Git server:

    install ruby 1.9+
    install rubygems if there was no one installed with ruby
    gem install murmurs

murmurs gem should install a new command 'murmurs' (In some OS, the script name maybe changed to murmurs1.9 for ruby 1.9).

Install the git hook post-receive (you may need to execute as the user having write permission to the git repository path) on Git server:

    murmurs -a <git repository path>

Then, in the git repository, setup the following configs:

    git config hooks.minglemurmursurl "https://<your-site>.mingle-api.thoughtworks.com/api/v2/projects/<your-project>/murmurs.xml"
    git config hooks.mingleaccesskeyid <Mingle user access key id>
    git config hooks.mingleaccesssecretkey <Mingle user access secret key>

After installed, try push a new commit to the server, and you should see something like the followings in your console:

    remote: murmur => your-project@your-site.mingle-api.thoughtworks.com

Note, the post-receive hook installed will never block you push commits to server, because Git calls the hook after the push work is done.

Test Git integration
-------------------

If you had concerns and want to try out before moving to production environment, try the followings:

Create a local git repository

    cd /tmp
    mkdir mingle_test
    cd mingle_test
    git init --bare

Setup murmurs git integration

    murmurs -a /tmp/mingle_test
    cd /tmp/mingle_test
    git config hooks.minglemurmursurl "https://<your-site>.mingle-api.thoughtworks.com/api/v2/projects/<your-project>/murmurs.xml"
    git config hooks.mingleaccesskeyid <Mingle user access key id>
    git config hooks.mingleaccesssecretkey <Mingle user access secret key>

Clone a local test repository

    cd /tmp
    git clone mingle_test mingle_test_local

Make an empty commit and push to origin master to trigger post-receive hook on origin repository

    cd mingle_test_local
    git commit --allow-empty -m "hello world, this is git mingle integration test"
    git push origin master

Test post a murmur on your project
-------------------

To confirm you can post a murmur to your Mingle project from the Git server with the configurations, you can run the following command:

    murmurs -m https://site-name.mingle-api.thoughtworks.com/api/v2/projects/your_project/murmurs.xml -k mingle_access_key_id -s mingle_access_secure_key  "This is a test."

Type "murmurs -h" for full details of the options available.
