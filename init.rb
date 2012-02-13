#
# vendor/plugins/redmine_etherpad/init.rb
#

require 'redmine'
require 'uri'

Redmine::Plugin.register :redmine_etherpad do
  name 'Redmine Etherpad plugin'
  author 'Charlie DeTar'
  description 'Embed etherpad-lite pads in redmine wikis.'
  version '0.0.1'
  url 'https://github.com/yourcelf/redmine-etherpad'
  author_url 'https://github.com/yourcelf'

  Redmine::WikiFormatting::Macros.register do
    desc "Embed etherpad"
    macro :etherpad do |obj, args|
      conf = Redmine::Configuration['etherpad']
      unless conf and conf['host'] 
        raise "Please define etherpad parameters in configuration.yml."
      end
      controls = {
        'showControls' => conf.fetch('showControls', true),
        'showChat' => conf.fetch('showChat', true),
        'showLineNumbers' => conf.fetch('showLineNumbers', false),
        'useMonospaceFont' => conf.fetch('useMonospaceFont', false),
        'noColors' => conf.fetch('noColors', false),
        'width' => conf.fetch('width', '640px'),
        'height' => conf.fetch('height', '480px'),
      }

      padname, *params = args
      for param in params
        key, val = param.strip().split("=")
        unless controls.has_key?(key)
          raise "#{key} not a recognized parameter."
        else
          controls[key] = val
        end
      end

      if User.current
        controls['userName'] = User.current.name
      elsif conf.fetch('loginRequired', true)
        return "TODO: embed read-only."
      end

      width = controls.delete('width')
      height = controls.delete('height')

      def hash_to_querystring(hash)
        hash.keys.inject('') do |query_string, key|
          query_string << '&' unless key == hash.keys.first
          query_string << "#{URI.encode(key.to_s)}=#{URI.encode(hash[key].to_s)}"
        end
      end
      
      return CGI::unescapeHTML("<iframe src='#{conf['host']}/p/#{padname}?#{hash_to_querystring(controls)}' width='#{width}' height='#{height}'></iframe>")
    end
  end
end
