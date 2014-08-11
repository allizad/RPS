module RPS

  class Register

    def self.run(params)
        if params['username'].empty? || params['password'].empty? || params['password_confirmation'].empty?
          return {:success? => false, :error => "Please fill out all input fields."}
        elsif RPS.dbi.username_exists?(params['username'])
          return {:success? => false, :error => "Username already exists. Please choose another username."}
        elsif params['password'] != params['password_confirmation']
          return {:success? => false, :error => "Passwords don't match.  Please try again."}
        elsif params['username'] == "tie"
          return {:success? => false, :error => "You cannot have the username 'tie'.  Please choose another username."}
        end

        @user = RPS::User.new(params['username'])
        @user.update_password(params['password'])
        RPS.dbi.register_user(@user)
        
        {
          :success? => true,
          :session_id => @user.username
        }
      end

  end

end