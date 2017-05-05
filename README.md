**NOTE: This repository is no longer supported or updated by GitHub. If you wish to continue to develop this code yourself, we recommend you fork it.**

# Albino: a ruby wrapper for pygmentize

This project is an extraction from GitHub.

For this and other extractions, see [http://github.com/github]()

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

