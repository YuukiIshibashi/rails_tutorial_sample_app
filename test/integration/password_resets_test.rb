require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
end

class ForgotPasswordFormTest < PasswordResets
  test "password reset path" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end
  
  test "不正なemailを入力した場合" do
    post password_resets_path, params: {
      password_reset: {
        email: "wrong@example.com"
      }
    }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets
  def setup
    super
    # createにpost(メール送信)
    post password_resets_path, params: {
      password_reset: {
        email: @user.email
      }
    }
    @reset_user = assigns(:user)
  end
end

# edit画面(再設定画面)のテスト
class PasswordFormTest < PasswordResetForm
  test "正しいemailの場合" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "不正なemailの場合" do
    get edit_password_reset_url(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "有効化されていないユーザの場合" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_url(@reset_user.reset_token, email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "emaiは正しいがtokenが不正な場合" do
    get edit_password_reset_url("wrongtoken", email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "email、token共に正しい場合" do
    get edit_password_reset_url(@reset_user.reset_token, email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

# updateのテスト
class PasswordUpdateTest < PasswordResetForm
  test "パスワードと確認が異なっていた場合" do
    patch password_reset_url(@reset_user.reset_token), params: {
      user: {
        password: "000000",
        password_confirmation: "111111"
      },
      email: @user.email
    }
    assert_select 'div#error_explanation'
    assert_select 'li', "Password confirmation doesn't match Password"
  end

  test "パスワードを空で送信した場合" do
    patch password_reset_url(@reset_user.reset_token), params: {
      user: {
        password: "",
        password_confirmation: ""
      },
      email: @user.email
    }
    assert_select 'div#error_explanation'
    assert_select 'li', "Password can't be empty"
  end

  test "正しいパスワードで送信した場合" do
    patch password_reset_url(@reset_user.reset_token), params: {
      user: {
        password: "000000",
        password_confirmation: "000000"
      },
      email: @user.email
    }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
    assert_nil @user.reload.reset_digest
  end

end

class ExpiredToken < PasswordResets
  def setup
    super
    # パスワードリセットのトークンを作成する
    post password_resets_path, params: {
      password_reset: {
        email: @user.email
      }
    }
    @reset_user = assigns(:user)
    # トークンを手動で失効させる
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # ユーザーのパスワードの更新を試みる
    patch password_reset_path(@reset_user.reset_token), params: {
      email: @reset_user.email,
      user: {
        password: "foobar",
        password_confirmation: "foobar"
      }
    }
  end
end

class ExpiredTokenTest < ExpiredToken
  test "should redirect to the password-reset page" do
    assert_redirected_to new_password_reset_url
  end

  test "should include the word 'expired' on the password-reset page" do
    follow_redirect!
    assert_match /expired/i, response.body
  end
end



# class PasswordResetsTest < PasswordResets
#   test "不正なemailを入力した場合" do
#     get new_password_reset_path
#     post password_resets_path, params: {
#       password_reset: {
#         email: "wrong@example.com"
#       }
#     }
#     assert_select 'div.alert', "Email address not found"
#   end

#   test "正しいemailを入力した場合" do
#     post password_resets_path, params: {
#       password_reset: {
#         email: @user.email
#       }
#     }
#     @reset_user = assigns(:user)
#     assert @reset_user.authenticated?(:reset, @reset_user.reset_token)
#     get edit_password_reset_url(@reset_user.reset_token, email: @reset_user.email)
#     assert_template 'password_resets/edit'
#     patch password_reset_url(@reset_user.reset_token), params: {
#       user: {
#         password: "000000",
#         password_confirmation: "000000"
#       },
#       email: @user.email
#     }
#     @reset_user.reload
#     assert @reset_user.authenticated?(:password, @reset_user.password)
#   end
# end
