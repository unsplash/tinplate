# Tinplate

Wrapper 'round the [TinEye API](https://services.tineye.com/developers/tineyeapi/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tinplate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tinplate

## Configuration

First you've got to let Tinplate know what your TinEye API keys are. In a Rails app, for example, this would go in an initializer, e.g. `config/intitializers/tinplate.rb`:

```ruby
Tinplate.configure do |config|
  config.public_key  = "YOUR PUBLIC API KEY"
  config.private_key = "YOUR PRIVATE API KEY"
  config.test        = false
end
```

If `test` is set to `true` (which is also the default), Tinplate will use [TinEye's test keys and sandbox environment](https://services.tineye.com/developers/tineyeapi/sandbox.html).


## Usage

There are only three API actions available: `search`, `remaining_searches` (to check the status of your account), and `image_count` (if you're curious how many total images TinEye has indexed).

`remaining_searches` returns an `OpenStruct` object with three attributes: `remaining_searches`, `start_date`, and `expire_date`.

`image_count` returns a plain old integer.

### Search examples

#### Search by URL

```ruby
tineye = Tinplate::TinEye.new
results = tineye.search(image_url: "http://example.com/photo.jpg")

results.stats.total_results    # => 2
results.stats.total_backlinks  # => 3
results.matches                # => an Array of matched images (see below)

results.matches.each do |match|
  # Do what you like with this matched image. The world is your oyster.
end
```

#### Search by upload

```ruby
tineye = Tinplate::TinEye.new
results = tineye.search(image_path: "/home/alice/example.jpg")
```

#### Optional search parameters

`offset`: Default 0    
`limit`:  Default 100    
`sort`:   "score", "size", or "crawl_date". Default "score".    
`order`:  "asc" or "desc". Default "desc".

#### Example matched image

An `OpenStruct` object with the following attributes (/w example values):

```ruby
domain: "ucsb.edu",
top_level_domain: "ucsb.edu",
width: 400
height: 300
size: 50734,
filesize: 195840,
score: 88.9,
tags: ["collection"],
image_url: "http://images.tineye.com/result/0f1e84b7b7538e8e7de048f4d45eb8f579e3e999941b3341ed9a754eb447ebb1",
format: "JPEG",
contributor: true,
overlay: "overlay/507bb6bf9a397284e2330be7c0671aadc7319b4b/0f1e84b7b7538e8e7de048f4d45eb8f579e3e999941b3341ed9a754eb447ebb1?m21=-9.06952e-05&m22=0.999975&m23=0.0295591&m11=0.999975&m13=-0.0171177&m12=9.06952e-05",
backlinks:
  # These are also OpenStruct objects, not Hashes.
  [
    {
      url: "http://example-copier.com/photo.jpg",
      crawl_date: "2012-06-30",
      backlink: "http://example-copier.com/photo.jpg"
    }
  ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unsplash/tinplate. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

