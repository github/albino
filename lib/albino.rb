require 'albino/process'
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
#   @syntaxer = Albino.new('/some/file.rb', :ruby)
#   puts @syntaxer.colorize
#
# This'll print out an HTMLized, Ruby-highlighted version
# of '/some/file.rb'.
#
# To use another formatter, pass it as the third argument:
#
#   @syntaxer = Albino.new('/some/file.rb', :ruby, :bbcode)
#   puts @syntaxer.colorize
#
# You can also use the #colorize class method:
#
#   puts Albino.colorize('/some/file.rb', :ruby)
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

  VERSION = '1.2.0'

  class << self
    attr_accessor :bin
  end
  self.bin = 'pygmentize'

  def self.colorize(*args)
    new(*args).colorize
  end

  def initialize(target, lexer = :text, format = :html)
    @target  = target
    @options = { :l => lexer, :f => format }
  end

  def execute(options = {})
    proc_options = {}
    proc_options[:timeout] = options.delete(:timeout) || 5
    command = convert_options(options)
    command.unshift(bin)
    Process.new(command, env={}, proc_options.merge(:input => write_target))
  end

  def colorize(options = {})
    execute(options).out
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
    if value !~ /^[a-z\-\_\+\#\,\s]+$/i
      raise ShellArgumentError, "Flag value is invalid: -#{flag} #{value.inspect}"
    end
  end

  def bin
    self.class.bin
  end
end
