Murmurs
================

Murmurs is a rubygem provides command to post a murmur message to your Mingle project.

Murmur
----------------

After installed gem, please run:

    murmurs -h

For details of how to config and post murmur to your project.

Integrate Mingle Murmurs with Git
----------------

On your Git server:

    install ruby
    install rubygems if there was no one installed with ruby
    gem install murmurs

murmurs gem should install a new command murmurs-git (In some OS, the script name maybe changed to murmurs-git1.9 for ruby 1.9)

Install the git hook post-receive:

    murmurs-git <mingle repository path>

Then, in the git repository, we need setup the following configs:

    git config hooks.minglemurmursurl "https://your-site.mingle-api.thoughtworks.com/api/v2/projects/your_project/murmurs.xml"
    git config hooks.mingleaccesskeyid <Mingle user access key id>
    git config hooks.mingleaccesssecretkey <Mingle user access secret key>

For further information about Mingle user access key id and secure key, please read:
http://www.thoughtworks.com/products/docs/mingle/current/help/configuring_hmac_authentication.html
