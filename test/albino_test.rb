require 'albino'
require 'rubygems'
require 'test/unit'
require 'mocha'

class AlbinoTest < Test::Unit::TestCase
  def setup
    @syntaxer = Albino.new(__FILE__, :ruby)
  end

  def test_defaults_to_text
    syntaxer = Albino.new(__FILE__)
    syntaxer.expects(:execute).with('pygmentize -f html -l text').returns(true)
    syntaxer.colorize
  end

  def test_accepts_options
    @syntaxer.expects(:execute).with('pygmentize -f html -l ruby').returns(true)
    @syntaxer.colorize
  end

  def test_works_with_strings
    syntaxer = Albino.new('class New; end', :ruby)
    assert_match %r(highlight), syntaxer.colorize
  end

  def test_aliases_to_s
    assert_equal @syntaxer.colorize, @syntaxer.to_s
  end

  def test_class_method_colorize
    assert_equal @syntaxer.colorize, Albino.colorize(__FILE__, :ruby)
  end
end