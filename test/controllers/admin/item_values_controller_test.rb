require "test_helper"

class Admin::ItemValuesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_item_values_index_url
    assert_response :success
  end

  test "should get edit" do
    get admin_item_values_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_item_values_update_url
    assert_response :success
  end
end
