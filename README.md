icanhaz
=======

There's no need to check this code out and run it yourself.  These services are available now!  Go read the [icanhazip FAQ](https://major.io/icanhazip-com-faq/) on my blog for more details.

This is some of the code behind the scenes of some goofy websites like:

* [icanhazip.com](http://icanhazip.com)
* [icanhazptr.com](http://icanhazptr.com)
* [icanhaztrace.com](http://icanhaztrace.com)
* [icanhaztraceroute.com](http://icanhaztraceroute.com)
* [icanhazepoch.com](http://icanhazepoch.com)
* [icanhazproxy.com](http://icanhazproxy.com)

It's Apache 2.0 licensed and it's poorly written code. ;)

*Enjoy! -- Major Hayden*

Deploying the Container
=======================

If you _do_ want to deploy this yourself:
* Build the container:
    * `make container`
* Run the container:
    * `docker run --restart=unless-stopped --name icanhaz-1 -i -d -p 46000:5000 --log-opt max-size=20m --log-opt max-file=5 lykinsbd/icanhaz:latest`
* Profit!