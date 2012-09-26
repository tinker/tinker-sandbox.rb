require 'sinatra/base'
require 'base64'

module Tinker
  class Sandbox < Sinatra::Base
    set :root, File.expand_path('../..', __FILE__)

    post '/' do
      code = params[:tinker][:code]
      tinker = {
        :deps => {
          :scripts => [],
          :styles => []
        },
        :code => {
          :html => Base64.decode64(code[:markup][:body]),
          :css => Base64.decode64(code[:style][:body]),
          :js => Base64.decode64(code[:behaviour][:body])
        }
      }
      headers 'X-Frame-Options' => ''
      body erb :index, :locals => {:tinker => tinker}
    end
  end
end

