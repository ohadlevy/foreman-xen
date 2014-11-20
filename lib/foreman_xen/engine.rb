require 'fast_gettext'
require 'gettext_i18n_rails'
require 'fog'
require 'deface'

module ForemanXen
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine

    initializer 'foreman_xen.register_gettext', :after => :load_config_initializers do |app|
      locale_dir    = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman-xen'

      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_xen.register_plugin', :after => :finisher_hook do |app|
      Foreman::Plugin.register :foreman_xen do
        requires_foreman '>= 1.5'
        # Register xen compute resource in foreman
        compute_resource ForemanXen::Xenserver
      end

    end

    config.to_prepare do
      begin
        # extend fog xen server and image models.
        require 'fog/xenserver/models/compute/server'
        require File.expand_path('../../../app/models/concerns/fog_extensions/xenserver/server', __FILE__)
        require File.expand_path('../../../app/models/concerns/foreman_xen/host_helper_extensions', __FILE__)

        Fog::Compute::XenServer::Server.send(:include, ::FogExtensions::Xenserver::Server)
        ::HostsHelper.send(:include, ForemanXen::HostHelperExtensions)
      rescue => e
        puts "Foreman-Xen: skipping engine hook (#{e.to_s})"
      end
    end

  end




end
