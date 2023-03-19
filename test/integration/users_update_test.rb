require "test_helper"

class UsersUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:archer)
  end

  test "(other)should not allow the admin attribute to be edited via the web" do
    log_in_as(@user)
    patch user_path(@user), params: {
      user: {
        name:  @user.name,
        email: @user.email,
        password: "",
        password_confirmation: "",
        admin: 1
      }
    }
    assert_not @user.admin?
  end
end
