require 'redmine'
require File.dirname(__FILE__) + "/lib/prologinid_connect/account_controller_patch"
require File.dirname(__FILE__) + "/lib/prologinid_connect/hooks"

Redmine::Plugin.register :prologinid_connect do
  name 'Redmine ProloginID Connect'
  author 'Léo Portemont'
  description 'Single Sign On With ProloginID'
  version '0.0.1'
  url 'https://github.com/prologin/redmine-prologinid-connect'
  author_url 'https://prologin.org'

  settings :default => {
    :client_id => "",
    :client_secret => "",
    :oauth_autentication => false,
    :keep_local_authentication => true,
    :token_endpoint_url => "",
    :authorize_endpoint_url => "",
    :userinfo_endpoint_url => "",
  }, :partial => 'settings/prologinid_connect_settings'
end

AccountController.send(:include, AccountControllerPatch)