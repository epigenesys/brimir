require("rails_helper")

describe(SettingsController) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:tenant) { FactoryBot.create(:tenant) }

  #TODO make the appropiate tests which are getting bodies either feature or view tests
  render_views

  before do
    sign_in(alice)
  end

  after { I18n.locale = :en }

  it("should create e-mailtemplates") do
    EmailTemplate.delete_all
    if (EmailTemplate.count == 0) then
      expect do
        put(:update, :params => ({ :id => tenant.id, :tenant => ({ :notify_user_when_account_is_created => true, :notify_client_when_ticket_is_created => true }) }))
      end.to(change { EmailTemplate.count }.by(2))
    end
  end

  it("enabled custom stylesheet set by tenant") do
    AppSettings.enable_custom_stylesheet = true
    AppSettings.custom_stylesheet_url = nil
    put(:update, :params => ({ :id => tenant.id, :tenant => ({ :stylesheet_url => "/tenant/custom.css" }) }))
    body = get(:edit).body
    expect(body).to(match(/<link[^>]+href="\/tenant\/custom.css"/))
    expect(body).to(match(/<input[^>]+stylesheet_url/))
    expect(body).not_to match(/<input[^>]+disabled[^>]+stylesheet_url/)
  end

  it("enabled custom stylesheet set by app settings") do
    AppSettings.enable_custom_stylesheet = true
    AppSettings.custom_stylesheet_url = "/appsettings/custom.css"
    put(:update, :params => ({ :id => tenant.id, :tenant => ({ :stylesheet_url => "/tenant/custom.css" }) }))
    body = get(:edit).body
    expect(body).to(match(/<link[^>]+href="\/appsettings\/custom.css"/))
    expect(body).to(match(/<input[^>]+disabled[^>]+stylesheet_url/))
  end
  it("disabled custom stylesheet") do
    AppSettings.enable_custom_stylesheet = false
    AppSettings.custom_stylesheet_url = "/appsettings/custom.css"
    body = get(:edit).body
    expect(body).not_to match(/<link[^>]+href="\/appsettings\/custom.css"/)
    expect(body).not_to match(/<input[^>]+stylesheet_url/)
  end

  it("enabled custom javascript set by tenant") do
    AppSettings.enable_custom_javascript = true
    AppSettings.custom_javascript_url = nil
    put(:update, :params => ({ :id => tenant.id, :tenant => ({ :javascript_url => "/tenant/custom.js" }) }))
    body = get(:edit).body
    expect(body).to(match(/<script[^>]+src="\/tenant\/custom.js"/))
    expect(body).to(match(/<input[^>]+javascript_url/))
    expect(body).not_to match(/<input[^>]+disabled[^>]+javascript_url/)
  end

  it("enabled custom javascript set by app settings ") do
    AppSettings.enable_custom_javascript = true
    AppSettings.custom_javascript_url = "/appsettings/custom.js"
    put(:update, :params => ({ :id => tenant.id, :tenant => ({ :javascript_url => "/tenant/custom.js" }) }))
    body = get(:edit).body
    expect(body).to(match(/<script[^>]+src="\/appsettings\/custom.js"/))
    expect(body).to(match(/<input[^>]+disabled[^>]+javascript_url/))
  end

  it("disabled custom javascript") do
    AppSettings.enable_custom_javascript = false
    AppSettings.custom_javascript_url = "/appsettings/custom.js"
    body = get(:edit).body
    expect(body).not_to match(/<script[^>]+src="\/appsettings\/custom.js"/)
    expect(body).not_to match(/<input[^>]+javascript_url/)
  end
end
