require 'test_helper'

class GameControllerTest < ActionController::TestCase
  setup do
    @score = scores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create score" do
    assert_difference('Score.count') do
      post :create, :score => @score.attributes
    end

    assert_redirected_to score_path(assigns(:score))
  end

  test "should show score" do
    get :show, :id => @score.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @score.to_param
    assert_response :success
  end

  test "should update score" do
    put :update, :id => @score.to_param, :score => @score.attributes
    assert_redirected_to score_path(assigns(:score))
  end

  test "should destroy score" do
    assert_difference('Score.count', -1) do
      delete :destroy, :id => @score.to_param
    end

    assert_redirected_to scores_path
  end
end
