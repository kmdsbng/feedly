# -*- encoding: utf-8 -*-
require 'uri'
require 'net/http'
require 'json'

class Feedly
  class Error      < StandardError; end
  class BadRequest < StandardError; end
  class AuthError  < StandardError; end
  class NotFound   < StandardError; end

  API_URL = 'http://sandbox.feedly.com/v3/'
  attr_reader :access_token

  def initialize(option)
    @access_token = option[:access_token]
  end

  def api_get(url)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Authorization'] = "OAuth #{self.access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    JSON.parse(response.body)
  end

  def get_profile
    api_get(make_url('profile'))
  end

  def get_preferences
    api_get(make_url('preferences'))
  end

  def make_url(path)
    Feedly::API_URL + path
  end

  def handle_errors(response)
    raise BadRequest if 'null' == response.body

    case response.code.to_i
    when 200 then response.body
    when 401 then raise AuthError
    when 403 then raise AuthError
    when 404 then raise NotFound
    when 500 then raise Error
    else
      raise Error
    end
  end
end


