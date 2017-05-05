require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require File.expand_path('app', File.dirname(__FILE__))

SmsVerification::App.run!
