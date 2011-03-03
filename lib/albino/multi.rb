require 'posix-spawn'

class Albino
  if !const_defined?(:ShellArgumentError)
    class ShellArgumentError < ArgumentError; end
  end

  class Multi
    include POSIX::Spawn

    class << self
      attr_accessor :bin, :timeout_threshold
    end

    self.timeout_threshold = 10
    self.bin = File.join(File.dirname(__FILE__), *%w(.. .. vendor multipygmentize))

    def self.colorize(*args)
      new(*args).colorize
    end

    def initialize(target, lexer = :text, *args)
      @spec = case target
        when Array
          @multi = true
          target
        else
          [[lexer, target]]
      end
    end

    def colorize(options = {})
      options[:timeout] ||= self.class.timeout_threshold
      options[:input]     = @spec.inject([]) do |memo, (lexer, code)|
        memo << lexer << SEPARATOR

        if code.respond_to?(:read)
          out = code.read
          code.close
          code = out
        end

        memo << code << SEPARATOR
      end.join("")
      child  = Child.new(self.class.bin, options)
      pieces = child.out.split(SEPARATOR)
      @multi ? pieces : pieces.first
    end

    alias_method :to_s, :colorize

    SEPARATOR = "\000".freeze
  end
end
