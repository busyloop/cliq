require "./spec_helper"
require "../examples/demo"

describe GreetWorld do
  it "says Hello world twice when --count 2" do
    stdout, _ = Stdio.capture do |io|
      Cliq.invoke(["greet", "world", "--count", "2"])
      [io.out.gets_to_end, io.err.gets_to_end]
    end

    stdout.should_not be_nil
    stdout.not_nil!.should eq("Hello world!\nHello world!\n")
  end

  it "says Hello world once when --count 1" do
    stdout, _ = Stdio.capture do |io|
      Cliq.invoke(["greet", "world", "--count", "1"])
      [io.out.gets_to_end, io.err.gets_to_end]
    end

    stdout.should_not be_nil
    stdout.not_nil!.should eq("Hello world!\n")
  end

  it "shows help on missing param" do
    stdout, _ = Stdio.capture do |io|
      Cliq.invoke(["greet", "world"])
      [io.out.gets_to_end, io.err.gets_to_end]
    end
    stdout.not_nil!.should contain("Missing option \"count\"")
  end
end

describe GreetPerson do
  it "shows help on missing param" do
    stdout, _ = Stdio.capture do |io|
      Cliq.invoke(["greet", "person"])
      [io.out.gets_to_end, io.err.gets_to_end]
    end
    stdout.not_nil!.should contain("Usage:")
    stdout.not_nil!.should contain("yell")
    stdout.not_nil!.should contain("Missing argument: <name>")
  end
end

describe Cliq do
  it "shows command list when no valid command is given" do
    stdout, _ = Stdio.capture do |io|
      Cliq.invoke(["derp"])
      [io.out.gets_to_end, io.err.gets_to_end]
    end
    stdout.not_nil!.should contain("Usage:")
    stdout.not_nil!.should contain("Greet someone")
    stdout.not_nil!.should contain("Greet the world")
  end

  it "shows command list when no command is given" do
    stdout, _ = Stdio.capture do |io|
      Cliq.invoke([] of String)
      [io.out.gets_to_end, io.err.gets_to_end]
    end
    stdout.not_nil!.should contain("Usage:")
    stdout.not_nil!.should contain("Greet someone")
  end

  # Can't easily test this because
  # Toka exits after displaying help.
  #
  # We'll just trust Toka's own tests for now...

  # it "shows command help when asked for it" do
  #   stdout, stderr = Stdio.capture do |io|
  #     Cliq.invoke(["greet", "--help"])
  #     [io.out.gets_to_end, io.err.gets]
  #   end
  #   stdout.not_nil!.should contain("Usage:")
  #   ...
  # end
end
