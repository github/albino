require 'albino'

class Albino
  # Wrapper for a custom multipygmentize script.  Passes multiple code
  # fragments in STDIN to Python.  This assumes both Python and pygments are
  # installed.
  #
  # Use like so:
  #
  #   @syntaxer = Albino::Multi.new([ [:ruby, File.open("/some/file.rb")] ])
  #   puts @syntaxer.colorize
  #
  # It takes an Array of two-element arrays [lexer, code].
  #
  # You can also use Albino::Multi as a drop-in replacement.  It currently has
  # a few limitations however:
  #
  # * Only the HTML output format is supported.
  # * UTF-8 encoding is forced.
  #
  # The default lexer is 'text'.  You need to specify a lexer yourself;
  # because we are using STDIN there is no auto-detect.
  #
  # To see all lexers and formatters available, run `pygmentize -L`.
  class Multi
    include POSIX::Spawn

    class << self
      attr_accessor :bin, :timeout_threshold
    end

    self.timeout_threshold = 10
    self.bin = File.join(File.dirname(__FILE__), *%w(.. .. vendor multipygmentize))

    # Initializes a new Albino::Multi and runs #colorize.
    def self.colorize(*args)
      new(*args).colorize
    end

    # This method accepts two forms of input:
    #
    # DEFAULT
    #
    # target - The Array of two-element [lexer, code] Arrays:
    #          lexer - The String lexer for the upcoming block of code.
    #          code  - The String block of code to highlight.
    #
    # LEGACY
    #
    # target - The String block of code to highlight.
    # lexer  - The String lexer for the block of code.
    #
    # Albino#initialize also takes format and encoding which are ignored.
    def initialize(target, lexer = :text, *args)
      @spec = case target
        when Array
          @multi = true
          target
        else
          [[lexer, target]]
      end
    end

    # Colorizes the code blocks.
    #
    # options - Specify options for the child process:
    #           timeout - A Fixnum timeout for the child process.
    #
    # Returns an Array of HTML highlighted code block Strings if an array of
    # targets are given to #initialize, or just a single HTML highlighted code
    # block String.
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
      pieces = child.out.split(SEPARATOR).each do |code|
        # markdown requires block elements on their own line
        code.sub!(%r{</pre></div>\Z}, "</pre>\n</div>")

        # albino::multi assumes utf8 encoding
        code.force_encoding('UTF-8') if code.respond_to?(:force_encoding)
      end
      @multi ? pieces : pieces.first
    end

    alias_method :to_s, :colorize

    SEPARATOR = "\000".freeze
  end
end
