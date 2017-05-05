require 'posix-spawn'

##
# Wrapper for the Pygments command line tool, pygmentize.
#
# Pygments: http://pygments.org/
#
# Assumes pygmentize is in the path.  If not, set its location
# with Albino.bin = '/path/to/pygmentize'
#
# Use like so:
#
#   @syntaxer = Albino.new('puts "Hello World"', :ruby)
#   puts @syntaxer.colorize
#
# This'll print out an HTMLized, Ruby-highlighted version
# of '/some/file.rb'.
#
# To use another formatter, pass it as the third argument:
#
#   @syntaxer = Albino.new('puts "Hello World"', :ruby, :bbcode)
#   puts @syntaxer.colorize
#
# You can also use the #colorize class method:
#
#   puts Albino.colorize('puts "Hello World"', :ruby)
#
# To format a file, pass a file stream:
#
#   puts Albino.colorize(File.new('/some/file.rb'), :ruby)
#
# Another also: you get a #to_s, for somewhat nicer use in Rails views.
#
#   ... helper file ...
#   def highlight(text)
#     Albino.new(text, :ruby)
#   end
#
#   ... view file ...
#   <%= highlight text %>
#
# The default lexer is 'text'.  You need to specify a lexer yourself;
# because we are using STDIN there is no auto-detect.
#
# To see all lexers and formatters available, run `pygmentize -L`.
#
# Chris Wanstrath // chris@ozmm.org
#         GitHub // http://github.com
#
class Albino
  class ShellArgumentError < ArgumentError; end
  include POSIX::Spawn

  VERSION = '1.3.3'

  class << self
    attr_accessor :bin, :timeout_threshold
    attr_reader :default_encoding

    def default_encoding=(encoding)
      # make sure the encoding is valid
      Encoding.find(encoding) if defined?(Encoding)

      @default_encoding = encoding
    end
  end

  self.timeout_threshold = 10
  self.default_encoding  = 'utf-8'
  self.bin = 'pygmentize'

  def self.colorize(*args)
    new(*args).colorize
  end

  def initialize(target, lexer = :text, format = :html, encoding = self.class.default_encoding)
    @target  = target
    @options = { :l => lexer, :f => format, :O => "encoding=#{encoding}" }
    @encoding = encoding
  end

  def execute(options = {})
    proc_options = {}
    proc_options[:timeout] = options.delete(:timeout) || self.class.timeout_threshold
    command = convert_options(options)
    command.unshift(bin)
    Child.new(*(command + [proc_options.merge(:input => write_target)]))
  end

  def colorize(options = {})
    out = execute(options).out

    # markdown requires block elements on their own line
    out.sub!(%r{</pre></div>\Z}, "</pre>\n</div>")

    # covert output to the encoding we told pygmentize to use
    out.force_encoding(@encoding) if out.respond_to?(:force_encoding)

    out
  end
  alias_method :to_s, :colorize

  def convert_options(options = {})
    @options.merge(options).inject([]) do |memo, (flag, value)|
      validate_shell_args(flag.to_s, value.to_s)
      memo << "-#{flag}" << value.to_s
    end
  end

  def write_target
    if @target.respond_to?(:read)
      out = @target.read
      @target.close
      out
    else
      @target.to_s
    end
  end

  def validate_shell_args(flag, value)
    if flag !~ /^[a-z]+$/i
      raise ShellArgumentError, "Flag is invalid: #{flag.inspect}"
    end
    if value !~ /^[a-z0-9\-\_\+\=\#\,\s]+$/i
      raise ShellArgumentError, "Flag value is invalid: -#{flag} #{value.inspect}"
    end
  end

  def bin
    self.class.bin
  end
end
