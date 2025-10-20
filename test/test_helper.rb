ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module AuthTestHelpers
  def sign_in_as(user, password: "password", organization: nil)
    post session_url, params: { email_address: user.email_address, password: password }
    assert_response :redirect
    
    org = organization || user.organizations.first
    session[:current_organization_id] = org.id if org
    
    follow_redirect!
  end
end

class ActionDispatch::IntegrationTest
  include AuthTestHelpers
end
