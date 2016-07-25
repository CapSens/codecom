# Capsens::Codecom

This gem automaticaly generates YARD compatible comments to your beloved methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capsens-codecom', git: 'projects.capsens.eu/engines/capsens-codecom'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capsens-codecom

## Usage

Run the following command in app root directory:

```
codecom
```

Here is the code before:

```ruby
module Example
    class Runner
        def template_options(line)
            {
              author_name: extract_author_name,
              method_name: extract_method_name(line),
              params_name: extract_method_arguments(line)
            }
        end
        
        def black_listed_methods
            [ :initialize, :permitted_params ]
        end
        
        def replace_template(data, options = {})
            data = data.gsub('%{method_name}', options.fetch(:method_name))
            data = data.gsub('%{author_name}', options.fetch(:author_name))
            data
        end
    end
end
```

And here is the code automatically commented after:

```ruby
module Example
    class Runner
    
        # @engine capsens-codecom
        # @timing 1469433025
        #
        # Describe here what the method should be used for.
        # Remember to add use case examples if possible.
        #
        # @author Yassine Zenati
        #
        # Examples:
        #
        #   template_options(line)
        #   #=> @return Expected returned value
        #
        # @param line [Class] Write param definition here.
        # @return [Class] Describe what the method should return.
        def template_options(line)
            {
              author_name: extract_author_name,
              method_name: extract_method_name(line),
              params_name: extract_method_arguments(line)
            }
        end
        
        # @engine capsens-codecom
        # @timing 1469433025
        #
        # Describe here what the method should be used for.
        # Remember to add use case examples if possible.
        #
        # @author Yassine Zenati
        #
        # Examples:
        #
        #   black_listed_methods
        #   #=> @return Expected returned value
        #
        # @return [Class] Describe what the method should return.
        def black_listed_methods
            [ :initialize, :permitted_params ]
        end
        
        # @engine capsens-codecom
        # @timing 1469433025
        #
        # Describe here what the method should be used for.
        # Remember to add use case examples if possible.
        #
        # @author Yassine Zenati
        #
        # Examples:
        #
        #   replace_template(data, options = {})
        #   #=> @return Expected returned value
        #
        # @param data [Class] Write param definition here.
        # @param options = {} [Class] Write param definition here.
        # @return [Class] Describe what the method should return.
        def replace_template(data, options = {})
            data = data.gsub('%{method_name}', options.fetch(:method_name))
            data = data.gsub('%{author_name}', options.fetch(:author_name))
            data
        end
    end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/capsens-codecom. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

