# -*- encoding: utf-8 -*-

def main
  token = Feedly.get_token
end

case $0
when __FILE__
  main
when /spec[^\/]*$/
  # {spec of the implementation}
end


