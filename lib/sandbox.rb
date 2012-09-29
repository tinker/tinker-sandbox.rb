require 'sinatra/base'
require 'base64'

module Tinker
  class Sandbox < Sinatra::Base
    set :root, File.expand_path('../..', __FILE__)

    post '/' do
      dependencies = params[:tinker][:dependencies]
      code = params[:tinker][:code]
      tinker = {
        :dependencies => {
          :scripts => [],
          :styles => []
        },
        :code => {
          :html => Base64.decode64(code[:markup][:body]),
          :css => Base64.decode64(code[:style][:body]),
          :js => Base64.decode64(code[:behaviour][:body])
        }
      }

      if dependencies && dependencies.length
        dependencies.each do |href|
          ext = (href.match(/(css|js)$/) || [])[1]
          if ext != 'css' && ext != 'js'
            ext = (href.match(/^(css|js)!/) || [])[1]
          end
          case ext
          when 'css'
            tinker[:dependencies][:styles] << href
          when 'js'
            tinker[:dependencies][:scripts] << href
          end
        end
      end

      if code[:style][:type] === 'less'
        source = Tempfile.new 'tinker'
        dest = Tempfile.new 'tinker'
        source.write tinker[:code][:css]
        source.close
        system "lessc #{source.path} #{dest.path}"
        source.unlink
        tinker[:code][:css] = dest.read
        dest.close
        dest.unlink
      end

      headers 'X-Frame-Options' => ''
      body erb :index, :locals => {:tinker => tinker}
    end
  end
end

