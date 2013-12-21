# -*- encoding: utf-8 -*-
require 'feedly'

def main
  access_token = ARGV[0]
  f = Feedly.new(:access_token => access_token)
  profile = f.get_profile
  puts profile[:fullName] # MyName
  puts profile[:client] # "Feedly sandbox client"
  puts profile[:email] # "myaddress@gmail.com"
end

case $0
when __FILE__
  main
when /spec[^\/]*$/
  # {spec of the implementation}
end


