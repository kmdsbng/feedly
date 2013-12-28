# -*- encoding: utf-8 -*-
require 'feedly'

def main
  feedly = Feedly.new
  puts '1. Access this url. Then redirect https://cloud.feedly.com/feedly.html?code=???&status= .'
  puts feedly.auth_url

  puts '2. Please input code'
  print '> '
  code = gets.chomp

  token = feedly.get_token_by_code(code)
  puts "OK. success to get tokens"
  puts "access_token: " + token["access_token"]
  puts "refresh_token: " + token["refresh_token"]
end

case $0
when __FILE__
  main
when /spec[^\/]*$/
  # {spec of the implementation}
end


