require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup
  test "invalid signup information" do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "user1",
                                         email: "user@valid.com",
                                         password:              "foobar",
                                         password_confirmation: "foobar" } }
      # follow_redirect!
      assert_equal 1, ActionMailer::Base.deliveries.size
    end
  end
end

class AccountActivationTest < UsersSignup
  def setup
     super
     post users_path, params: {
        user: {
          name:  "Example User",
          email: "user@example.com",
          password:              "password",
          password_confirmation: "password" 
        }
      }
      @user = assigns(:user)
  end

  test "まだ有効化されていない" do
    assert_not @user.activated?
  end

  test "有効化されていないユーザーをログイン可能にしてはならない" do
    delete logout_path
    log_in_as(@user)
    assert_redirected_to root_path
    assert_not @user.activated?
    assert_not is_logged_in?
  end

  test "無効なトークンでユーザーを有効化できてはならない" do
    delete logout_path
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not @user.activated?
    assert_not is_logged_in?
  end

  test "無効なメールアドレスでユーザーを有効化できてはならない" do
    delete logout_path
    get edit_account_activation_path(@user.activation_token, email:"invalid@example.com")
    assert_not @user.activated?
    assert_not is_logged_in?
  end

  test "有効なトークンとメールアドレスを使えばユーザーを有効化できること" do
    delete logout_path
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
