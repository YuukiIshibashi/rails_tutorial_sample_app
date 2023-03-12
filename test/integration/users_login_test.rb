require "test_helper"

class UserLogin < ActionDispatch::IntegrationTest
  def setup
    #  @user = User.create(name: "user1", email: "user@valid.com", password: "foobar")
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UserLogin
  test "login path" do
    get login_path
    assert_template 'sessions/new'
  end

  test "login with valid email/invalid password" do
    post login_path, params: { 
      session: { 
        email: @user.email,
        password: "invalid",
      }
    }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert flash[:danger]
    assert_template 'sessions/new'
    get root_path
    assert flash.empty?
  end

  test "login with invalid email/password" do
    post login_path, params: { 
      session: { 
        email: "user@invalid.com",
        password: "invalid",
      }
    }
    assert_response :unprocessable_entity
    assert flash[:danger]
    assert_template 'sessions/new'
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UserLogin
  def setup
    super
    post login_path, params: {
      session: {
        email: @user.email,
        password: "password"
      }
    }
  end
end

class ValidLoginTest < ValidLogin
  test "valid login" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "redirect after login" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

end

class LogOut < ValidLogin
  def setup
    super
    delete logout_path
  end

  test "Log out" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "redirect after logout" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end

