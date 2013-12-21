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

  def get_profile
    url = get_profile_url
    uri = URI(url)
    req = Net::HTTP::Get.new(uri.request_uri)

      #req['$Authorization.feedly'] = '$FeedlyAuth'
    req['Authorization'] = "OAuth #{self.access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    JSON.parse(response.body)
  end

  def get_profile_url
    Feedly::API_URL + 'profile'
    #argv.each do |k, v|
    #  url << "#{k}=#{v}&"
    #end
    #JSON.parse(FeedlyApi.get(url, @auth_token), symbolize_names: true)
  end

  def get_preferences
    url = get_preferences_url
    uri = URI(url)
    req = Net::HTTP::Get.new(uri.request_uri)

      #req['$Authorization.feedly'] = '$FeedlyAuth'
    req['Authorization'] = "OAuth #{self.access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    JSON.parse(response.body)
  end

  def get_preferences_url
    Feedly::API_URL + 'preferences'
    #argv.each do |k, v|
    #  url << "#{k}=#{v}&"
    #end
    #JSON.parse(FeedlyApi.get(url, @auth_token), symbolize_names: true)
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


