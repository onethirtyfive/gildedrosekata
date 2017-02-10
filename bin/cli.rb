#!/usr/bin/env ruby

$: << File.join(__dir__, '..', 'lib')

require 'gilded_rose'
require 'yaml'
require 'pp'

db_path  = File.join(__dir__, 'database.yml')
database = YAML.load_file(db_path)
items    = database.map { |attrs| GildedRose::Item.new(*attrs) }

def print_items(items)
  puts <<-EOV

> current database:

  EOV

  puts items.map(&:inspect)
end

loop do
  puts <<-EOV

choose one:
  1. print current data
  2. tick
  3. quit

  EOV

  print "> "
  choice = gets.chomp

  case choice
  when "1"
    print_items(items)
  when "2"
    items = items.map { |item| GildedRose.tick(item) }

    puts <<-EOV

> tick...

    EOV

    print_items(items)
  when "3"
    puts <<-EOV
> bai.
EOV
    break
  end

  puts
  puts
end

