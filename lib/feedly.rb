# -*- encoding: utf-8 -*-
require "feedly/version"
require 'uri'
require 'net/http'
require 'json'

class Feedly
  class Error      < StandardError; end
  class BadRequest < StandardError; end
  class AuthError  < StandardError; end
  class NotFound   < StandardError; end

  #API_URL = 'http://sandbox.feedly.com/v3/'
  attr_reader :access_token

  def initialize(option={})
    @refresh_token = option[:refresh_token]
    @access_token = option[:access_token]
    @sandbox = option[:sandbox]
    if !@access_token && @refresh_token
      get_access_token_by_refrech_token
    end
  end

  def api_root
    if @sandbox
      'http://sandbox.feedly.com'
    else
      'http://cloud.feedly.com'
    end
  end

  def client_id
    @client_id if @client_id
    if @sandbox
      'sandbox'
    else
      'feedly'
    end
  end

  def client_secret
    @client_secret if @client_secret
    if @sandbox
      'QNFQRFCFM1IQCJB367ON'
    else
      '0XP4XQ07VVMDWBKUHTJM4WUQ'
    end
  end

  def redirect_uri
    @redirect_uri if @redirect_uri
    if @sandbox
      'http://localhost'
    else
      'https://cloud.feedly.com/feedly.html'
    end
  end

  def auth_url
    api_get_redirect('auth/auth',
                   :client_id => self.client_id,
                   :redirect_uri => self.redirect_uri,
                   :scope => 'https://cloud.feedly.com/subscriptions',
                   :response_type => 'code',
                   :provider => 'google',
                   :migrate => 'false')
  end

  require 'pry'

  def get_token_by_code(code)
    #https://sandbox.feedly.com/v3/auth/token -X POST -d 'client_id=sandbox&client_secret=QNFQRFCFM1IQCJB367ON&grant_type=authorization_code&redirect_uri=http%3A%2F%2Flocalhost&code=AQAACggvIv3qZbrjYmz-Grq3r0POtTpduXUuKDd-4fQeO-yZisHCGQRSmZ-FDEMndQVCalBzBZuyceyEH0jJDSbTD42eqJU2dzVFT_qt0ak3wknJhx3xvHXc55gcYtC2YURCm-PDsFmFhLBdKQcK1pBlT-JX6K35_xx2vAmt1wOu'


    url = make_url('auth/token', {})
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Authorization'] = "OAuth #{self.access_token}"
    req['Content-type'] = 'application/json'
    req.set_form_data({
      :refresh_token => @refresh_token,
      :client_id => self.client_id,
      :client_secret => self.client_secret,
      :grant_type => 'authorization_code',
      :redirect_uri => self.redirect_uri,
      :code => code,
    })

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    JSON.parse(response.body)
  end

  def get_access_token_by_refrech_token
    url = make_url('auth/token', {})
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Authorization'] = "OAuth #{self.access_token}"
    req['Content-type'] = 'application/json'
    #req.body = body.to_json
    req.set_form_data({:refresh_token => @refresh_token, :client_id => 'sandbox', :client_secret => 'QNFQRFCFM1IQCJB367ON', :grant_type => 'refresh_token'})

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    json = JSON.parse(response.body)
    @access_token = json['access_token']
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

  def api_get_redirect(path, argv={})
    url = make_url(path, argv)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Authorization'] = "OAuth #{self.access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    if response.code.to_i == 302
      return response['location']
    end

    handle_errors(response)
    raise "Unknown state #{response.code}"
  end

  def api_post(path, body, argv={})
    url = make_url(path, argv)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Authorization'] = "OAuth #{self.access_token}"
    req['Content-type'] = 'application/json'
    req.body = body.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    true
  end

  def api_delete(path, argv={})
    url = make_url(path, argv)
    uri = URI(url)
    req = Net::HTTP::Delete.new(uri.request_uri)
    req['Authorization'] = "OAuth #{self.access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    handle_errors(response)
    true
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
    api_post('subscriptions', {:id => feed_id})
  end

  def delete_subscriptions(feed_id)
    api_delete('subscriptions/' + URI.encode_www_form_component(feed_id))
  end

  def post_topics(param)
    api_post('topics', param)
  end

  def delete_topics(topic_id)
    api_delete('topics/' + URI.encode_www_form_component(topic_id))
  end

  def make_url(path, argv)
    base_url = api_root + '/v3/' + path
    query = argv.map {|k, v|
      "#{URI.encode_www_form_component(k)}=#{URI.encode_www_form_component(v)}"
    }.join('&')
    query.empty? ? base_url : base_url + '?' + query
  end

  def handle_errors(response)
    raise BadRequest if 'null' == response.body

    case response.code.to_i
    when 200 then response.body
    when 401 then raise AuthError, response.body
    when 403 then raise AuthError, response.body
    when 404 then raise NotFound, response.body
    when 500 then raise Error, response.body
    else
      raise Error, response.body
    end
  end
end


