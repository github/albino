# coding: utf-8

require 'rubygems'
require 'albino/multi'
require 'test/unit'
require 'tempfile'
require 'mocha'

class MultiTest < Test::Unit::TestCase
  def setup
    @syntaxer = Albino::Multi.new(File.new(__FILE__), :ruby)
  end

  def test_defaults_to_text
    syntaxer = Albino::Multi.new('abc')
    regex    = /span/
    assert_no_match regex, syntaxer.colorize
  end

  def test_markdown_compatible
    code = Albino::Multi.colorize('1+2', :ruby)
    assert_no_match %r{</pre></div>\Z}, code
  end

  def test_forces_utf8
    code = Albino::Multi.colorize('1+2', :ruby)
    if code.respond_to?(:encoding)
      assert_equal 'UTF-8', code.encoding.to_s
    end
  end

  def test_accepts_utf8
    code = Albino::Multi.colorize('éøü', :html)
    assert_includes code, "<pre>éøü\n</pre>"
  end

  def test_works_with_strings
    syntaxer = Albino::Multi.new("class New\nend", :ruby)
    assert_match %r(highlight), code=syntaxer.colorize
    assert_match %(<span class="nc">New</span>\n), code
  end

  def test_works_with_multiple_code_fragments
    syntaxer = Albino::Multi.new [
      ['ruby', "class New\nend"],
      ['python', "class New:\n  pass"]]
    codes = syntaxer.colorize
    assert_equal 2, codes.size
    assert_match %r(highlight), codes[0]
    assert_match %r(highlight), codes[1]
    assert_match %(<span class="nc">New</span>\n), codes[0]
    assert_match %(<span class="p">:</span>),      codes[1]
  end

  def test_works_with_files
    contents = "class New\nend"
    syntaxer = Albino::Multi.new(contents, :ruby)
    file_output = syntaxer.colorize

    Tempfile.open 'albino-test' do |tmp|
      tmp << contents
      tmp.flush
      syntaxer = Albino::Multi.new(File.new(tmp.path), :ruby)
      assert_equal file_output, syntaxer.colorize
    end
  end

  def test_aliases_to_s
    syntaxer = Albino::Multi.new(File.new(__FILE__), :ruby)
    assert_equal @syntaxer.colorize, syntaxer.to_s
  end

  def test_class_method_colorize
    assert_equal @syntaxer.colorize, Albino::Multi.colorize(File.new(__FILE__), :ruby)
  end
end

