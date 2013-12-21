# charcoal

JSONP ("JSON with padding") and CORS (Cross-Origin Resource Sharing) filtration for Rails versions 2 and above.

## Usage

### JSONP

Include the module `Charcoal::JSONP` in the controller you'd like to allow JSONP.
You may then use `allow_jsonp` class method with the following options:

```ruby
# directive is a method (symbol) or block (taking one argument, the controller instance)
allow_jsonp method [method2 ...], :if => directive, :unless => directive
```

`:all` is also a valid argument that applies to all methods. The default (with no arguments) is the same as `:all`.

Requests that come in with a callback parameter (e.g. `http://test.com/users.json?callback=hello`)
will have the response body wrapped in that callback and the content type changed to `application/javascript`

### CORS

Please familiarize yourself with the [documentation](https://developer.mozilla.org/En/HTTP_access_control) ([wikipedia](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing)) before proceeding.

Include the module `Charcoal::CORS` in the controller you'd like to allow CORS.
`allow_cors` accepts the same arguments as `allow_jsonp`

Included is a CORS pre-flight controller that must be hooked up to the Rails router:

Rails 2:
```ruby
map.connect "*path.:format", :conditions => { :method => :options }, :action => "preflight", :controller => "CORS", :namespace => "charcoal/"
```

Rails 3:
```ruby
match '*path.:format' => 'charcoal/C_O_R_S#preflight', :via => :options
```

#### Configuration

The configuration options and defaults for CORS are as follows:

```ruby
# Access-Control-Allow-Origin
Charcoal.configuration["allow-origin"] # => "*"
# Can be set to a string
Charcoal.configuration["allow-origin"] = "https://google.com"
# Or a block
Charcoal.configuration["allow-origin"] = lambda do |controller|
  controller.request.host
end

# Access-Control-Allow-Headers
"allow-headers" => ["X-Requested-With", "X-Prototype-Version"]

# Sets Access-Control-Allow-Credentials
"credentials" => true

# Access-Control-Allow-Headers
"expose-headers" => []

# Access-Control-Max-Age
"max-age" => 86400
```

### Creating Your Own Filter

It's possible to create your own controller filter like so:

```ruby
require 'charcoal/controller_filter'

module MyFilter
  def self.included(klass)
    klass.extend(ClassMethods)
    klass.before_filter :quack, :if => :animals_allowed?
  end

  module ClassMethods
    include Charcoal::ControllerFilter

    def animals_allowed
      @animals_allowed ||= Hash.new(lambda {|_| false})
    end

    allow :animals do |method, directive|
      animals_allowed[method] = directive
    end
  end

  def animals_allowed?
    self.class.animals_allowed[params[:action]].call(self)
  end

  protected

  def quack
    Rails.logger.info("QUACK!")
  end
end
```

This example adds the `allow_animals` directive that logs "QUACK!" if an applicable request is received.

## Supported Versions

Tested with Ruby 1.9.3 and 2.0 and Rails 2.3 and 3.2.
[![Build Status](https://secure.travis-ci.org/steved555/charcoal.png?branch=master)](http://travis-ci.org/steved555/charcoal)

## Contributing to charcoal

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Steven Davidovitz. See LICENSE for
further details.

