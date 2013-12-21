# -*- encoding: utf-8 -*-

def main
  feedly = Feedly.new
  puts '1. Access this url. Then redirect http://localhost?code=???&status= .'
  puts feedly.auth_url

  puts '2. Please input code'
  code = gets

  token = feedly.get_token_by_code(code)
  puts "access_token: " + token.access_token
  puts "refresh_token: " + token.refresh_token
end

case $0
when __FILE__
  main
when /spec[^\/]*$/
  # {spec of the implementation}
end


