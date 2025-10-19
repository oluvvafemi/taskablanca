require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    sign_in_as @user
  end

  test "should return empty results for empty query" do
    get search_path
    assert_response :success
    assert_select "turbo-frame#search-results"
  end

  test "should find matching tasks" do
    get search_path, params: { q: "design" }
    assert_response :success
    assert_select "turbo-frame#search-results"
    assert_select "h6", text: /design/i
  end

  test "should find matching projects" do
    get search_path, params: { q: "website" }
    assert_response :success
    assert_select "turbo-frame#search-results"
    assert_select "h6", text: /website/i
  end

  test "should return no results for non-matching query" do
    get search_path, params: { q: "nonexistent" }
    assert_response :success
    assert_select "turbo-frame#search-results"
    assert_select "p", text: /No results found/
  end
end
