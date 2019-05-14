require 'test_helper'

class TicketAssigningTest < ActionDispatch::IntegrationTest
  setup do
    Tenant.current_domain = tenants(:main).domain
    Capybara.current_driver = Capybara.javascript_driver
    host! "test.host"
  end

  test 'shows a link to assign a ticket' do
    visit ticket_path(tickets(:problem))
    save_and_open_screenshot
  end
end
