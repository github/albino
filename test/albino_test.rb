require 'albino'
require 'rubygems'
require 'test/unit'
require 'tempfile'
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
    syntaxer = Albino.new("class New\nend", :ruby)
    assert_match %r(highlight), syntaxer.colorize
  end

  def test_works_with_files
    contents = "class New\nend"
    syntaxer = Albino.new(contents, :ruby)
    file_output = syntaxer.colorize

    Tempfile.open 'albino-test' do |tmp|
      tmp << contents
      tmp.flush
      syntaxer = Albino.new(tmp.path, :ruby)
      assert_equal file_output, syntaxer.colorize
    end
  end

  def test_aliases_to_s
    assert_equal @syntaxer.colorize, @syntaxer.to_s
  end

  def test_class_method_colorize
    assert_equal @syntaxer.colorize, Albino.colorize(__FILE__, :ruby)
  end
end