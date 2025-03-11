require "test_helper"

class Admin::PlantsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get admin_plants_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_plants_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_plants_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_plants_destroy_url
    assert_response :success
  end
end
