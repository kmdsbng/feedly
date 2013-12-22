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

  def api_get(path, argv={})
    url = make_url(path, argv)
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
    api_get('profile')
  end

  def get_preferences
    api_get('preferences')
  end

  def get_categories
    api_get('categories')
  end

  def get_subscriptions
    api_get('subscriptions')
  end

  def get_topics
    api_get('topics')
  end

  def get_tags
    api_get('tags')
  end

  def get_search_feeds(q, n=20)
    api_get('search/feeds', :q => q, :n => n)
  end

  def get_feeds(feed_id)
    api_get('feeds/' + URI.encode_www_form_component(feed_id))
  end

  def post_subscriptions(feed_id)
    argv = {}
    url = make_url('subscriptions', argv)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Authorization'] = "OAuth #{self.access_token}"
    req['Content-type'] = 'application/json'

    req.body = {:id => feed_id}.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    true
  end


  def delete_subscriptions(feed_id)
    argv = {}
    url = make_url('subscriptions/' + URI.encode_www_form_component(feed_id), argv)
    uri = URI(url)
    req = Net::HTTP::Delete.new(uri.request_uri)
    req['Authorization'] = "OAuth #{self.access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    true
  end

  def make_url(path, argv)
    base_url = Feedly::API_URL + path
    query = argv.map {|k, v|
      "#{URI.encode_www_form_component(k)}=#{URI.encode_www_form_component(v)}"
    }.join('&')
    query.empty? ? base_url : base_url + '?' + query
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


