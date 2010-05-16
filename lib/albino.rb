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
  VERSION = '1.0'

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

  def execute(command)
    output = ''
    IO.popen(command, mode='r+') do |p|
      write_target_to_stream(p)
      p.close_write
      output = p.read.strip
    end
    output
  end

  def colorize(options = {})
    execute bin + convert_options(options)
  end
  alias_method :to_s, :colorize

  def convert_options(options = {})
    @options.merge(options).inject('') do |string, (flag, value)|
      string + " -#{flag} #{value}"
    end
  end

  def write_target_to_stream(stream)
    if @target.respond_to?(:read)
      @target.each { |l| stream << l }
      @target.close
    else
      stream << @target
    end
  end

  def bin
    self.class.bin
  end
end