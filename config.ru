$:.unshift File.expand_path('.') + '/lib'
require 'bundler/setup'
require 'sandbox'
run Tinker::Sandbox

