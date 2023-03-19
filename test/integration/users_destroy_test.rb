require "test_helper"

class UsersDestroy < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end
end

class UsersDestroyAdminTest < UsersDestroy
  def setup
    super
    log_in_as(@admin)
  end

  test "should not allow the admin attribute to be edited via the web" do
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end
end

class UsersDestroyNotTest < UsersDestroy
  def setup
    super
    log_in_as(@non_admin)
  end

  test "should be able to delete non-admin user" do
    assert_no_difference 'User.count' do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end