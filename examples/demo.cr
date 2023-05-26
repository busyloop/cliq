require "../src/cliq"

class GreetWorld < Cliq::Command
  command "greet world"
  summary "Greet the world"   # Shown on top-level help-screen
  description "World greeter" # Shown on command help-screen

  flags({
    count: Int32,
  })

  # `#call` gets called when your command is invoked.
  #
  # It's the only mandatory method that your Cliq::Command
  # subclass must have. Here you can see how to access the
  # flag values (`@count`) and positional args (`args`).
  def call(args)
    @count.times do
      puts "Hello world!"
    end
  end
end

class GreetPerson < Cliq::Command
  command "greet person"
  summary "Greet someone"
  args ["<name> Name to greet"]

  # See https://github.com/Papierkorb/toka#advanced-usage
  flags({
    yell:  Bool?,
    count: {
      type:        Int32,
      default:     1,
      value_name:  "TIMES",
      description: "Print the greeting this many times (default: 1)",
    },
  })

  def call(args)
    raise Cliq::Error.new("Missing argument: <name>") if args.size < 1
    greeting = "Hello #{args[0]}!"
    greeting = greeting.upcase if @yell
    @count.times do
      puts greeting
    end
  end
end

class Ping < Cliq::Command
  command "ping"
  summary "Minimum viable example"

  def call(args)
    puts "pong"
  end
end

# Let's go!
Cliq.invoke(ARGV) unless ENV["ENV"]? == "test"
