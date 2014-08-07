module RPS

  class SignIn

    def self.run(params)
      if params['username'].empty? || params['password'].empty?
        return {:success? => false, :error => "Please fill out all input fields."}
      end

      @user = RPS.dbi.get_user_by_username(params['username'])
      return {:success? => false, :error => "Username not found. Please try again."} if !@user

      if !@user.has_password?(params['password'])
        return {:success? => false, :error => "Incorrect password. Please try again."}
      end

      {
        :success? => true,
        :session_id => @user.username
      }
    end

  end

end