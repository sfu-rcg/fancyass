# Fancyass

A modular Hiera backend that consumes API responses. Each module (aka application) is considered a trouser for fancyass to wear.

List of available trousers:

* foreman

Unlike other Hiera backends, fancyass will only make one call out to The Foreman during a node's Puppet run, <b>*for all lookups*</b> (such fancy, much amaze, wow). It does this using timestamps (grabbed from scope, see foreman.rb). This considerably reduces the load on The Foreman, and speeds up your node's run slightly. If you're not writing the returned values to disk, they're stored in an instance variable for quick & easy returns on subsequent lookups.

## Installation

* Clone the repo on your Puppet Master.

```bash
git clone https://github.com/sfu-rcg/fancyass.git
```

* Install the required Ruby gems.

```bash
cd fancyass
bundle install
```

* Run rake as a privileged user, optionally setting PUPPET_LIB to the directory where you want fancyass to be installed. It must be located in one of Ruby's load paths (`ruby -e 'puts $:'`). It defaults to the first path in $: (`ruby -e 'puts $:.first'`).

```bash
rake
# OR
PUPPET_LIB=/some/ruby/load/path rake
```

* Install [sfu-rcg's foreman_param_lookup](https://github.com/sfu-rcg/foreman_param_lookup) plugin on your Foreman server, and ensure it works.

* Set fancyass options in your hiera.yaml file.

## Configuration - hiera.yaml

The following values must be set underneath :fancyass:. The spacing, and semi-colons are important. Do not quote booleans!

#####`:debug`
Must be set to either true or false (defaults to false). Invalid values will set this to false.

#####`:trouser`
Must be set to an available trouser (i.e. a Ruby file in fancyass_wardrobe/trousers/).

### Trousers

####foreman

The following values must be set underneath :foreman:.

#####`:url:`
The URL of your Foreman server.

#####`:user:`
The user to use to authenticate

#####`:password:`
The password for the above user

#####`:search_key:`
This will be used as the key for searching & identifying your hosts. Acceptable values are: fqdn, clientcert, and macaddress.

#####`:request_headers:`
An optional hash that allows you to specify request headers for the connection to the Foreman server.

#####`:output:`
An optional hash that allows you to choose how to handle the Foreman's response. If not provided, fancyass will simply return the value for key lookups as they're requested. This however prevents Hiera from merging those values with other backends.

#####`:disk:`
A key underneath :output: that will write the response from The Foreman to disk so that it can be merged with other backends (ex: yaml, or json). The file will be written to wherever :datadir is set to in hiera.yaml (folder must exist), otherwise it will write the file to Hiera's default location for your system (ex: /var/lib/hiera for \*nix). 

#####`:format:`
A key underneath :output: that will set the format of the file. Acceptable values are: yaml, and json.

Full example:

```yaml
---
:backends:
  - fancyass
  - yaml

:hierarchy:
  - "%{::fqdn}"
  - defaults

:yaml:
  :datadir: "/etc/puppet/environments/%{::environment}/data"

:fancyass:
  :debug: true
  :trouser: 'foreman'
  :foreman:
    :url: 'https://foreman.domain.com'
    :user: 'admin'
    :password: 'changeme'
    :search_key: 'fqdn'
    :request_headers:
      :Accept: 'application/json'
    :output:
      :disk: true
      :format: 'yaml'
```

## Contributing

### Versioning

This repo uses [Semantic Versioning](http://semver.org/).

### Branching

Please adhere to the branching guidelines set out by Vincent Driessen in this [post](http://nvie.com/posts/a-successful-git-branching-model/).

### Guidelines

All trouser files must: 

* be underneath fancyass_wardrobe/trousers/
* have a lowercase filename that matches the class name
* be nested inside of the Hiera class, Backend module, and finally the Fancyass module
* implement a lookup method

There are a variety of methods located in the Fancyass module that you can re-use (see fancyass_wardrobe/accessories/bling.rb).

### Issues

Please submit any issues [here](https://github.com/sfu-rcg/fancyass/issues).

## License

Copyright (c) 2014 Simon Fraser University

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
