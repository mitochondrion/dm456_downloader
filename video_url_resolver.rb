#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require "mechanize"
require "execjs"
require "uri"

class VideoUrlResolver
  attr_reader :url

  BASE_URI = 'http://v2.tudou.com/v.action'

  def initialize(url)
    @url = url
  end

  def video_url
    URI(BASE_URI).tap { |uri| uri.query = params }.to_s
  end

  private

  def params
    pv = metadata["pv"]
    URI.encode_www_form(si: "10200", hd: "2", vn: "02", it: pv, retc: "1")
  end

  def metadata
    js_string = script_tag.text.match(/var dm456 = ({.*})/)[1]
    ExecJS.eval(js_string)
  end

  def script_tag
    page.search("head script").detect { |tag| tag.text[/var dm456 = /] }
  end

  def page
    @page ||= agent.get(url)
  end

  def agent
    @agent ||= Mechanize.new
  end
end

if __FILE__==$0
  require "pry"
  url = "http://www.dm456.com/donghua/1399/73353.html"
  todou_url = VideoUrlResolver.new(url).video_url
  
  agent = Mechanize.new do |a|
    a.proxy_host = 'localhost'
    a.proxy_port = 8888
  end

  binding.pry
end
