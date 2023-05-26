require "toka" # 💖

#
# Fight smart, harm few, score big.
# -- Black Sam Bellamy
#

class Cliq
  class Error < Exception; end

  EXE = File.basename(Process.executable_path.not_nil!)

  @@command_map = {} of String => Cliq::Command.class

  def self.command(cmd_path : String, cmd_class)
    @@command_map[cmd_path] = cmd_class
  end

  def self.invoke(argv = ARGV)
    args = [] of String
    argv.each do |arg|
      next if arg[0] == '-'
      args << arg
    rescue
      next
    end

    cmd : Cliq::Command.class | Nil = nil
    guess : Array(String)? = nil

    n = args.size - 1
    commands = @@command_map.keys.sort!
    part = ""
    loop do
      part = args[0..n].join(" ")
      n -= 1
      cmd = @@command_map[part]?
      break if cmd
      guess = commands.select(&.starts_with?(part)) unless part == ""
      break if n < 0
    end

    if cmd
      begin
        raise Cliq::Error.new(nil) if argv.includes?("-h") || argv.includes?("--help")

        🍺 = cmd.new(argv)
        pos_opts = 🍺.positional_options
        (0..n + 1).each do
          pos_opts.shift
        end
        🍺.call(pos_opts)
      rescue ex : Toka::MissingOptionError | Toka::ConversionError | Toka::UnknownOptionError | Cliq::Error
        puts "\nUsage: #{EXE} #{part} #{cmd.args.map { |e| e.split(" ")[0] }.join(" ")}"

        if desc = cmd.description
          puts
          desc.split("\n").each do |line|
            print "  "
            puts line
          end
        end

        unless cmd.args.empty?
          indent = cmd.args.max_of { |e| e.includes?(" ") ? e.split(" ")[0].size : 0 }
          if 0 < indent
            puts
            cmd.args.each do |pos_arg_spec|
              if pos_arg_spec.includes? " "
                spec, desc = pos_arg_spec.split(" ", 2)
                print "  #{spec}"
                lines = desc.split("\n")
                print " " * (indent - spec.size + 2)
                lines.each_with_index do |line, i|
                  puts line
                  print " " * (indent + 4) unless i == lines.size - 1
                end
              end
            end
          end
        end

        puts Toka::HelpPageRenderer.new(cmd)
        puts "\e[31;1m" + ex.message.not_nil! + "\n\n" unless ex.message.nil?
      end
      return
    end

    🦮(guess)
  end

  def self.🦮(guess)
    puts "\nUsage: #{EXE} <command> [--help]\n\n"
    cmd_names = @@command_map.keys.sort!
    max_width = cmd_names.max_of(&.size)
    cmd_names.each do |cmd_name|
      cmd = @@command_map[cmd_name].not_nil!
      print "\e[33;1m" if guess.try &.includes? cmd_name
      print "  #{cmd_name}"
      print "\e[0m"
      if cmd.summary == ""
        puts
      else
        lines = cmd.summary.split("\n")
        print " " * (max_width - cmd_name.size + 3)
        lines.each_with_index do |line, i|
          puts line
          print " " * (max_width + 5) unless i == lines.size - 1
        end
      end
    end
    puts
  end
end

abstract class Cliq::Command
  abstract def call(args : Array(String))

  class_getter summary : String = ""
  class_getter description : String? = nil
  class_getter args : Array(String) = [] of String

  def self.command(name : String)
    Cliq.command(name, self)
  end

  def self.summary(text : String)
    @@summary = text
  end

  def self.description(text : String)
    @@description = text
  end

  def self.args(args : Array(String))
    @@args = args
  end

  macro flags(*args)
    Toka.mapping({{*args}})
  end

  macro inherited
    Toka.mapping({} of String => String)
  end
end
