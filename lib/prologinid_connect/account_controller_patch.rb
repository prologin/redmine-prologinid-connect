module AccountControllerPatch
    def self.included base
        base.send :prepend, AccountControllerExtension

        base.class_eval do
          unloadable
        end
    end

    def no_local_signin
        flash[:error] = l(:local_signin_not_enabled)
        redirect_to signin_path
    end


    module AccountControllerExtension
        def local_signin
            return Setting.plugin_prologinid_connect[:keep_local_authentication]
        end

        def authenticate_user
            return super if local_signin
            no_local_signin
        end

        def lost_password
            return super if local_signin
            no_local_signin
        end

        def activate
            return super if local_signin
            no_local_signin
        end

        def register
            return super if local_signin
            no_local_signin
        end
    end
end