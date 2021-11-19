require 'account_controller'
require 'json'

class RedmineOauthController < AccountController

  def prologin_oauth
    if Setting.plugin_prologinid_connect[:oauth_authentication]
      session[:back_url] = params[:back_url]
      redirect_to oauth_client.auth_code.authorize_url(:redirect_uri => prologin_oauth_callback_url, :scope => scopes)
    else
      password_authentication
    end
  end

  def prologin_oauth_callback
    if params[:error]
      flash[:error] = l(:notice_access_denied)
      redirect_to signin_path
    else
      token = oauth_client.auth_code.get_token(params[:code], :redirect_uri => prologin_oauth_callback_url)
      result = token.get(settings[:userinfo_endpoint_url])
      info = JSON.parse(result.body)
      if info && info["email_verified"]
        try_to_login info
      else
        flash[:error] = l(:notice_unable_to_obtain_credentials)
        redirect_to signin_path
      end
    end
  end

  def get_roles info
    roles = info["resource_access"][settings[:client_id]]
    return [] if roles == nil
    return [] if roles["roles"] == nil
    return roles["roles"]
  end

  def user_has_role info, role
    return get_roles(info).include? role
  end

  def apply_groups info, user
    groups_to_add = get_roles(info).select { |r| r.start_with? "redmine::group::" }
    groups_to_add.map! { |r| Integer(r.delete_prefix("redmine::group::")) }
    user.groups.each do | group |
      unless groups_to_add.include? group.id
        puts("removing #{user.to_s} from #{group.to_s}")
        user.groups.delete(group.id)
      else
        groups_to_add.delete group.id
      end
    end

    groups_to_add.each do | gid |
      group = Group.find(gid)
      puts("adding #{user.to_s} to group #{group.to_s}")
      user.groups << group
    end
  end

  def username_or_legacy_login info
    return info["legacy_redmine_username"] if info.has_key? "legacy_redmine_username"
    return info["preferred_username"]
  end

  def update_user info, user
    user.firstname = info["given_name"]
    user.lastname = info["family_name"]
    user.mail = info["email"]
    user.password = nil
    user.admin = user_has_role info, "redmine::superuser"
    return user
  end

  def try_to_login info
   params[:back_url] = session[:back_url]
   session.delete(:back_url)
   unless user_has_role info, "redmine::access"
    flash[:error] = l(:notice_not_authorized_to_access_application)
    redirect_to signin_path
    return
   end
   user = User.where(login: username_or_legacy_login(info)).first_or_create
    if user.new_record?
      user.login = username_or_legacy_login(info)
      user = update_user info, user
      user.register
      user.activate
      user.save!
      apply_groups info, user

      successful_authentication(user)
    elsif user.active?
      user = update_user info, user
      user.save!
      apply_groups info, user
      successful_authentication(user)
    else
      account_pending(user)
    end
  end

  def oauth_client
    @client ||= OAuth2::Client.new(settings[:client_id], settings[:client_secret],
      :authorize_url => settings[:authorize_endpoint_url],
      :token_url => settings[:token_endpoint_url])
  end

  def settings
    @settings ||= Setting.plugin_prologinid_connect
  end

  def scopes
    'profile roles email legacy_identities'
  end

end
