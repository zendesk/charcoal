# charcoal

JSONP ("JSON with padding") and CORS (Cross-Origin Resource Sharing) filtration.

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

Include the module `Charcoal::CrossOrigin` in the controller you'd like to allow CORS.
`allow_cors` accepts the same arguments as `allow_jsonp`

Included is a CORS pre-flight controller that must be hooked up to the Rails router:

```ruby
match '*path', :to => 'charcoal/cross_origin#preflight', :via => :options
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

# Access-Control-Expose-Headers
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

## Supported Versions

Ruby >= 3.2 and Rails >= 7.0

[![CI status](https://github.com/zendesk/charcoal/actions/workflows/ci.yml/badge.svg)](https://github.com/zendesk/charcoal/actions/workflows/ci.yml)

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. update version in all `Gemfile.lock` files,
3. merge this change into `main`, and
4. look at [the action](https://github.com/zendesk/charcoal/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/charcoal/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.

## Contributing to charcoal

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

See LICENSE for further details.
