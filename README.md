# Cliq [![Build](https://github.com/busyloop/cliq/workflows/Build/badge.svg)](https://github.com/busyloop/cliq/actions?query=workflow%3ABuild+branch%3Amaster) [![GitHub](https://img.shields.io/github/license/busyloop/cliq)](https://en.wikipedia.org/wiki/MIT_License) [![GitHub release](https://img.shields.io/github/release/busyloop/cliq.svg)](https://github.com/busyloop/cliq/releases)

The quick way to create a user-friendly **Command Line Interface** in Crystal. ⚡powered by [Toːka](https://github.com/Papierkorb/toka)

![](./examples/demo.gif)


## Features

* Easily create a CLI with nested sub-commands and complex flags
* Automatic help screens, argument type coercion, input validation and meaningful error messages



## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cliq:
       github: busyloop/cliq
   ```

2. Run `shards install`



## Basic Usage

```crystal
require "cliq"

class GreetPerson < Cliq::Command
  # Declare the command name, description and help-text(s) for positional arguments
  command "greet person", "Greet someone", ["<name> Name to greet"]

  # Declare the flags for this command
  flags({
    yell: Bool?,
    count: {
      type: Int32,
      default: 1,
      value_name: "TIMES",
      description: "Print the greeting this many times"
    }
  })

  def call(args)
    raise Cliq::Error.new("Must provide a <name>") if args.size < 1
    greeting = "Hello #{args[0]}!"
    greeting = greeting.upcase if @yell
    @count.times { puts greeting }
  end
end

# Let's go!
Cliq.invoke(ARGV)
```



## How it works

* You can have any number of `Cliq::Command` subclasses in your program.
  Cliq merges them together to form the final CLI.
* Each must have a method  `#call(args : Array(String))`.
* Use the  `command`-macro to declare the _command name_, _description_ and _description of positional arguments_
  * The latter two are optional.
  * Spaces are allowed in the _command name_.
    If you want a sub-command `foo bar batz` then just put exactly that in there.
* Use the `flags`-macro to declare the flags that your command accepts

* See [examples/demo.cr](./examples/demo.cr) for a demo with multiple sub-commands



## The `flags`-macro

### Short-hand syntax

```crystal
flags({
  verbose: Bool?,
  count: Int32
})
```

This allows `--verbose` or `-v`  (optional)
and requires  `--count N` or `-c N`  (where N must be an integer).

### Long-hand syntax

```crystal
flags({
  verbose: {
    type: Bool,
    nilable: true,
    description: "Enable verbosity"
  }
  count: {
    type: Int32,
    description: "Print the greeting this many times",
    verifier: ->(n : Int32){ n >= 0 || "Must be greater than zero" }
  }
})
```

#### Reference

- `type` The type. Examples: `String`, `Int32?`, `Array(String)`
- `nilable` If the type is optional ("nil-able"). You can also make the `type` nilable for the same effect.
- `default` The default value.
- `description` The human-readable description. Can be multi-line.
- `long` Allows to manually configure long-options. Auto-generated from the name otherwise.
- `short` Allows to manually configure short-options. Auto-generated otherwise. Set to `false` to disable.
- `value_name` Human-readable value name, shown next to the option name like: `--foo=HERE`
- `category` Human-readable category name, for grouping in the help page. Optional.
- `value_converter` [Converter](https://github.com/Papierkorb/toka#converters) to use for the value.
- `key_converter` [Converter](https://github.com/Papierkorb/toka#converters) for the key to use for a `Hash` type.
- `verifier` [Verifier](https://github.com/Papierkorb/toka#input-verification) to validate the value.



## Credits

Cliq is a thin wrapper around [Toːka](https://github.com/Papierkorb/toka).
Please refer to the [Toːka documentation](https://github.com/Papierkorb/toka#advanced-usage) for advanced usage.

If you do not need sub-commands in your program
then you should consider using Toːka directly.



## Contributing

1. Fork it (<https://github.com/busyloop/cliq/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

