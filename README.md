# RunAfterCommit

Run code in an ActiveRecord model after it is committed

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'run_after_commit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install run_after_commit

## Usage

Include `RunAfterCommit` in your model and queue some code:

```ruby
class SomeModel < ActiveRecord::Base
  include RunAfterCommit

  after_save :some_method

  def some_method
    run_after_commit do
      # Runs when the model is committed
    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/run_after_commit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
