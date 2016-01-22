require 'bundler/setup'
require "pg"
require "pry"
require "sinatra/base"
require "sinatra/reloader"

require_relative "server"

run Forum::Server