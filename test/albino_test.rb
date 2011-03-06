# coding: utf-8

require 'rubygems'
require 'albino'
require 'test/unit'
require 'tempfile'
require 'mocha'

class AlbinoTest < Test::Unit::TestCase
  def setup
    @syntaxer = Albino.new(File.new(__FILE__), :ruby)
  end

  def test_defaults_to_text
    syntaxer = Albino.new('abc')
    regex    = /span/
    assert_no_match regex, syntaxer.colorize
  end

  def test_accepts_options
    assert_match /span/, @syntaxer.colorize
  end

  def test_accepts_non_alpha_options
    assert_equal '', @syntaxer.colorize(:f => 'html+c#-dump')
  end

  def test_works_with_strings
    syntaxer = Albino.new("class New\nend", :ruby)
    assert_match %r(highlight), code=syntaxer.colorize
    assert_match %(<span class="nc">New</span>\n), code
  end

  def test_works_with_utf8_strings
    code = Albino.new("# é", :bash).colorize
    assert_match %r(highlight), code
    assert_match %r(<span class="c"># .*</span>), code
  end

  def test_works_with_files
    contents = "class New\nend"
    syntaxer = Albino.new(contents, :ruby)
    file_output = syntaxer.colorize

    Tempfile.open 'albino-test' do |tmp|
      tmp << contents
      tmp.flush
      syntaxer = Albino.new(File.new(tmp.path), :ruby)
      assert_equal file_output, syntaxer.colorize
    end
  end

  def test_aliases_to_s
    syntaxer = Albino.new(File.new(__FILE__), :ruby)
    assert_equal @syntaxer.colorize, syntaxer.to_s
  end

  def test_class_method_colorize
    assert_equal @syntaxer.colorize, Albino.colorize(File.new(__FILE__), :ruby)
  end

  def test_escaped_shell_args
    assert_raises Albino::ShellArgumentError do
      @syntaxer.convert_options(:l => "'abc;'")
    end
  end
end
