require "toka" # 💖

#
# Fight smart, harm few, score big.
# -- Black Sam Bellamy
#

class Cliq
  class Error < Exception; end

  EXE = File.basename(Process.executable_path.not_nil!)

  @@command_map = {} of String => { Cliq::Command.class, String, Array(String) }?

  def self.command(cmd_path : String, cmd_class, desc = "", pos_arg_spec = [] of String)
    @@command_map[cmd_path] = { cmd_class, desc, pos_arg_spec }
  end

  def self.invoke(argv=ARGV)
    args = [] of String
    argv.each do |arg|
      next if arg[0] == '-'
      args << arg
    rescue
      next
    end

    cmd : { Cliq::Command.class, String, Array(String) }? = nil
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
        raise Cliq::Error.new(nil) if argv.includes?("-h") || argv.includes?("--help") || argv.includes?("-----ArrrRRrgh!!1!")

        🍺 = cmd[0].new(argv)
        pos_opts = 🍺.positional_options
        (0..n+1).each do
          pos_opts.shift
        end
        🍺.call(pos_opts)
      rescue ex : Toka::MissingOptionError | Toka::ConversionError | Toka::UnknownOptionError | Cliq::Error
        puts "\nUsage: #{EXE} #{part} #{cmd[2].map { |e| e.split(" ")[0] }.join(" ")}"

        unless cmd[2].empty?
          indent = cmd[2].max_of { |e| e.includes?(" ") ? e.split(" ")[0].size : 0 }
          if 0 < indent
            puts
            cmd[2].each do |pos_arg_spec|
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

        puts Toka::HelpPageRenderer.new(cmd[0])
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
      if cmd[1] == ""
        puts
      else
        lines = cmd[1].split("\n")
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

  def self.command(cmd_path : String, desc = "", pos_args = [] of String)
    Cliq.command(cmd_path, self, desc, pos_args)
  end

  macro flags(*args)
    Toka.mapping({{*args}})
  end

  macro inherited
    Toka.mapping({} of String => String)
  end
end
