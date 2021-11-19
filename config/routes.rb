get 'prologinid/login', :to => 'redmine_oauth#prologin_oauth'
get 'prologinid/complete', :to => 'redmine_oauth#prologin_oauth_callback', :as => 'prologin_oauth_callback'