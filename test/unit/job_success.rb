#!/usr/bin/env ruby

def factorial(n)
  factorial = 1
  1.upto(n) do |x|
    factorial = factorial * x
  end
  return factorial
end

raise "Missing integer for factorial" if ARGV.size == 0 and ARGV[0].nil?
number = ARGV[0]
raise "Must be valid non-negative integer" unless number.to_s.match(/^\d+$/)
puts factorial(number.to_i)
