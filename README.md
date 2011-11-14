# Albino: a ruby wrapper for pygmentize

This project is an extraction from GitHub.

For this and other extractions, see [http://github.com/github]()

**Note**: This library is deprecated in favor of [pygments.rb](https://github.com/tmm1/pygments.rb).

## Installation

    sudo easy_install pygments
    gem install albino

## Usage

### Simple

    require 'albino'
    puts Albino.colorize('puts "Hello World"', :ruby)

### Advanced

    require 'albino'
    @syntaxer = Albino.new(File.new('albino.rb'), :ruby, :bbcode)
    puts @syntaxer.colorize

### Multi

    require 'albino/multi'
    ruby, python = Albino::Multi.colorize([ [:ruby,'1+2'], [:python,'1-2'] ])

