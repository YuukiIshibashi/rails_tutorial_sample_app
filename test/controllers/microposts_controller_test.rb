require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_url, params: {
        micropost: {
          content: "gggg"
        }
      }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_url(@micropost)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong micropost" do
    @user = users(:michael)
    log_in_as(@user)
    @other_post = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_url(@other_post)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
