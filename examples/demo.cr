require "../src/cliq"

class GreetWorld < Cliq::Command
  # `flags` declares the flags that
  # this command will recognize.
  #
  # We'll keep it simple for this first example
  # and only have a mandatory Int32 option
  # called "--count".
  flags({
    count: Int32
  })

  # `command` registers this class with Cliq.
  # It takes up to 3 arguments:
  #
  # 1. Command name (required, may contain spaces)
  # 2. Description (optional, shown on help screen)
  # 3. Array of positional arguments (optional, shown on help screen)
  #
  # We use only the first two here because our command
  # doesn't take any positional arguments.
  command "greet world", "Greet the world"

  # `#call` gets called when your command is invoked.
  #
  # It's the only mandatory method that your Cliq::Command
  # subclass must have. Here you can see how to access the
  # option values (`@count`) and positional args (`args`).
  def call(args)
    @count.times do
      puts "Hello world!"
    end
  end
end

class GreetPerson < Cliq::Command
  # See https://github.com/Papierkorb/toka#advanced-usage
  flags({
    yell: Bool?,
    count: {
      type: Int32,
      default: 1,
      value_name: "TIMES",
      description: "Print the greeting this many times (default: 1)"
    }
  })

  command "greet person", "Greet someone", ["<name> Name to greet"]

  def call(args)
    raise Cliq::Error.new("Missing argument: <name>") if args.size < 1
    greeting = "Hello #{args[0]}!"
    greeting = greeting.upcase if @yell
    @count.times do
      puts greeting
    end
  end
end

# Let's go!
Cliq.invoke(ARGV) unless ENV["ENV"]? == "test"
