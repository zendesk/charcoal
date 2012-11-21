# charcoal

JSONP ("JSON with padding") and CORS (Cross-Origin Resource Sharing) filtration for Rails versions 2 and above.

## Usage

### JSONP

Include the module `Charcoal::JSONP` in the controller you'd like to allow JSONP.
You may then use `allow_jsonp` class method with the following options:


Requests that come in with a callback parameter (e.g. `http://test.com/users.json?callback=hello`)
will have the response body wrapped in that callback and the content type changed to `application/javascript`

### CORS

Include the module `Charcoal::CORS` in the controller you'd like to allow CORS.
Preflight controller...


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

