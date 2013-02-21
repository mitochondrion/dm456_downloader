#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require "mechanize"
require "pry"
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
  url = "http://www.dm456.com/donghua/1399/73353.html"
  puts VideoUrlResolver.new(url).video_url
end

