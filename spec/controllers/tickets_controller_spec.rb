require("rails_helper")
RSpec.describe(TicketsController, :type => :controller) do
  let!(:alice) { FactoryBot.create(:user, :with_agent, name: 'Alice', email: 'alice@xxxx.com', notify: true) }
  let!(:bob) { FactoryBot.create(:user, name: 'Bob', email: 'bob@xxxx.com') }
  let!(:charlie) { FactoryBot.create(:user, :with_agent, name: 'Charlie', email: 'charlie@xxxx.com', schedule_enabled: false) }
  let!(:ticket) { FactoryBot.create(:ticket, :with_to_email_address, user: bob, assignee: alice) }

  before do
    @simple_email = file_fixture('ticket_mailer/simple').read
    @simple_base64_email = file_fixture('ticket_mailer/simple_base64').read
    @mailgun_message_url = "https://storage.mailgun.net/v3/domains/mg.test.com/messages/eyJwIjpmYWxzZSwiafI6IjJhZGNhMzkxLWVhMTItNDc4OS1iZjg5LTliNjQ1NDEyZWMyMCIsInMiOiJiYmFjNzc1YmIzIiwiYyI6InRhbmtiIn0="
  end

  after do
    Timecop.return
    I18n.locale = :en
  end

  it("should get new as customer") do
    sign_in(bob)
    get(:new)
    expect(response).to have_http_status(:success)
  end

  it("should get new as agent") do
    sign_in(alice)
    get(:new)
    expect(response).to have_http_status(:success)
  end

  it("should get new as anonymous") do
    get(:new)
    expect(response).to have_http_status(:success)
  end

  it("acceptable mail hooks (for extra safety)") do
    expect(["post-mail", "mailgun"]).to(eq(TicketsController::MAIL_HOOKS))
  end

  it("should create ticket when posted from MTA") do
    I18n.locale = :nl

    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
    end.to change{Ticket.count}.from(1).to(2)

    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should create ticket when posted from Mailgun") do
    eval("      class RestClient::Resource\n        def initialize(url, user:, password:, headers:)\n          fail \"bad url\" unless url == '#{@mailgun_message_url}'\n          fail \"bad user\" unless user == 'api'\n          fail \"bad headers\" unless headers == { accept: 'message/rfc2822' }\n        end\n\n        def get\n          OpenStruct.new(body: File.read(Rails.root.join('spec/fixtures/files/ticket_mailer/mailgun')))\n        end\n      end\n")
    I18n.locale = :nl

    expect do
      post(:create, :params => ({ :hook => "mailgun", :mail_key => (TicketsController::MAIL_KEY), :"message-url" => (@mailgun_message_url), :format => :json }))
      expect(response).to have_http_status(:success)
    end.to change{ Ticket.count }

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.html_part.body.decoded).to(match("View ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should accept tickets in Base64 encoding") do
    I18n.locale = :nl
    expect do
      expect do
        post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_base64_email), :format => :json }))
        expect(response).to have_http_status(:success)
      end.to change { Ticket.count }
    end.to change{ActionMailer::Base.deliveries.size}
  end

  it("should write email and name to user") do
    sign_in(alice)
    post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :name => "Tester", :content => "Foobar", :subject => "Foobar" }) }))
    user = Ticket.last.user
    expect("test@test.nl").to(eq(user.email))
    expect("Tester").to(eq(user.name))
  end

  it("should create ticket when signed in and captcha") do
    sign_in(alice)
    post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
    expect(Ticket.count).to eq 2
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

  it("should not create ticket when ivalid and captcha and signed in") do
    sign_in(alice)
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "invalid", :content => "", :subject => "" }) }))
      expect(response).to have_http_status(:success)
    end.to_not change{ Ticket.count }

    expect(ActionMailer::Base.deliveries.size).to eq(0)
    expect(assigns(:ticket).notified_users.count).to eq(0)
  end

  it("should create ticket when not signed in and captcha") do
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      # expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should not create ticket when not signed in and invalid and captcha") do
    expect do
      expect do
        post(:create, :params => ({ :ticket => ({ :from => "invalid", :content => "", :subject => "" }) }))
        expect(response).to have_http_status(:success)
      end.to_not(change { Ticket.count })
    end.to_not(change { ActionMailer::Base.deliveries.size })
    expect(assigns(:ticket).notified_users.count).to(eq(0))
  end

  it("should create ticket when signed in and no captcha") do
    secret_key = Recaptcha.configuration.secret_key
    site_key = Recaptcha.configuration.site_key
    Recaptcha.configuration.secret_key = ""
    Recaptcha.configuration.site_key = ""
    sign_in(alice)
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
    end.to(change { Ticket.count }.by(1))
    Recaptcha.configuration.secret_key = secret_key
    Recaptcha.configuration.site_key = site_key
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))

    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

  it("should not create ticket when signed in and invalid and no captcha") do
    secret_key = Recaptcha.configuration.secret_key
    site_key = Recaptcha.configuration.site_key
    Recaptcha.configuration.secret_key = ""
    Recaptcha.configuration.site_key = ""
    sign_in(alice)
    expect do
      expect do
        post(:create, :params => ({ :ticket => ({ :from => "invalid", :content => "", :subject => "" }) }))
        expect(response).to have_http_status(:success)
      end.to_not(change { Ticket.count })
    end.to_not(change { ActionMailer::Base.deliveries.size })
    Recaptcha.configuration.secret_key = secret_key
    Recaptcha.configuration.site_key = site_key
    expect(assigns(:ticket).notified_users.count).to(eq(0))
  end

  it("should create ticket when not signed in and no captcha") do
    secret_key = Recaptcha.configuration.secret_key
    site_key = Recaptcha.configuration.site_key
    Recaptcha.configuration.secret_key = ""
    Recaptcha.configuration.site_key = ""

    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      # expect(response).to have_http_status(:success)
    end.to(change { Ticket.count }.by(1))
    Recaptcha.configuration.secret_key = secret_key
    Recaptcha.configuration.site_key = site_key
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

  it("should not create ticket when not signed in and no captcha") do
    secret_key = Recaptcha.configuration.secret_key
    site_key = Recaptcha.configuration.site_key
    Recaptcha.configuration.secret_key = ""
    Recaptcha.configuration.site_key = ""

    expect do
      post(:create, :params => ({ :ticket => ({ :from => "invalid", :content => "", :subject => "" }) }))
      expect(response).to have_http_status(:success)
    end.to_not(change { Ticket.count })
    Recaptcha.configuration.secret_key = secret_key
    Recaptcha.configuration.site_key = site_key
    expect(assigns(:ticket).notified_users.count).to(eq(0))
    expect(ActionMailer::Base.deliveries.size).to eq(0)
  end

  it("should notify agent when schedule is nil and ticket is created from MTA") do
    agent = alice
    agent.schedule = nil
    agent.save!
    agent.reload
    expect(agent.schedule).to(be_nil)
    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

  it("should notify agent with schedule disabled when ticket is created from MTA") do
    agent = charlie
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to be_falsey
    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent with schedule enabled and day within work day range when ticked created from MTA") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 00:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent with schedule enabled and time within range working hours when ticked created from MTA") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 23:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should not notify agent with schedule enabled and day not within working days range when ticked created from MTA") do
    agent = charlie
    agent.schedule = FactoryBot.create(:part_time_schedule)
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    expect(agent.schedule_enabled).to(be_truthy)
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule.monday?).to(eq(true))
    expect(agent.schedule.tuesday?).to(eq(true))
    expect(agent.schedule.wednesday?).to(eq(true))
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-03 00:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should not notify agent with schedule enabled and time not within range working hours when ticked created from MTA") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "22:00"
    agent.save!
    agent.reload
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("22:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 23:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

  it("should notify agent when schedule is nil when ticket is created") do
    agent = alice
    agent.schedule = nil
    agent.save!
    agent.reload
    expect(agent.schedule).to(be_nil)
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent with schedule disabled when ticket is created") do
    agent = charlie
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to be_falsey

    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent with schedule enabled and day within work day range when ticked created") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 00:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent with schedule enabled and time within range working hours when ticked created") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 23:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should not notify agent with schedule enabled and day not within working days range when ticked created") do
    agent = charlie
    agent.schedule = FactoryBot.create(:part_time_schedule)
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    expect(agent.schedule_enabled).to(be_truthy)
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule.monday?).to(eq(true))
    expect(agent.schedule.tuesday?).to(eq(true))
    expect(agent.schedule.wednesday?).to(eq(true))
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-03 00:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect(ActionMailer::Base.deliveries.size).to eq(0)
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    #TODO Should this be creating an email or not? The wording of the title is confusing
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should not notify agent with schedule enabled and time not within range working hours when ticked created") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "22:00"
    agent.save!
    agent.reload
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("22:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 23:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      expect(response).to have_http_status(:success)
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent when schedule is nil when ticket is created with logged in agent") do
    agent = alice
    agent.schedule = nil
    agent.save!
    agent.reload
    sign_in(agent)
    expect(agent.schedule).to(be_nil)
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      # assert_redirected_to(ticket_url(assigns(:ticket)))
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent with schedule disabled when ticket is created with logged in agent") do
    agent = charlie
    sign_in(agent)
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to be_falsey
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent with schedule enabled and day within work day range when ticked created with logged in agent") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    sign_in(agent)
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 00:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      # assert_redirected_to(ticket_url(assigns(:ticket)))
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should notify agent with schedule enabled and time within range working hours when ticked created with logged in agent") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    sign_in(agent)
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 00:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to(match("New ticket"))
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should not notify agent with schedule enabled and day not within working days range when ticked created with logged in agent") do
    agent = charlie
    agent.schedule = FactoryBot.create(:part_time_schedule)
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "23:00"
    agent.save!
    agent.reload
    sign_in(agent)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule.monday?).to(eq(true))
    expect(agent.schedule.tuesday?).to(eq(true))
    expect(agent.schedule.wednesday?).to(eq(true))
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("23:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-03 00:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should not notify agent with schedule enabled and time not within range working hours when ticked created with logged in agent") do
    agent = charlie
    agent.schedule_enabled = true
    agent.schedule.start = "00:00"
    agent.schedule.end = "22:00"
    agent.save!
    agent.reload
    sign_in(agent)
    expect(agent.schedule).to_not(be_nil)
    expect(agent.schedule_enabled).to(be_truthy)
    expect(Time.find_zone("UTC").parse("00:00")).to(eq(agent.schedule.start))
    expect(Time.find_zone("UTC").parse("22:00")).to(eq(agent.schedule.end))
    new_time = Time.find_zone(agent.time_zone).parse("2016-12-02 23:00")
    Timecop.freeze(new_time)
    expect(Time.now).to(eq(new_time))
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
    end.to(change { Ticket.count })
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(assigns(:ticket).notified_users.count).to_not(eq(0))
  end

  it("should only allow agents to view others tickets") do
    sign_in(bob)
    get(:show, :params => ({ :id => FactoryBot.create(:ticket, user: charlie, assignee: alice, message_id: 'test124@test124') }))
    expect(response).to have_http_status(:unauthorized)
  end

  it("should get index") do
    sign_in(alice)
    get(:index)
    expect(response).to have_http_status(:success)
    expect(assigns(:tickets)).to_not(be_nil)
  end

  it("should get csv index") do
    sign_in(alice)
    get(:index, :format => :csv)
    expect(response).to have_http_status(:success)
    expect(assigns(:tickets)).to_not(be_nil)
  end

  context 'order tickets' do
    let!(:high_priority) { FactoryBot.create(:ticket, priority: :high, user: charlie, assignee: alice,  created_at: 8.days.ago) }
    let!(:medium_priority) { FactoryBot.create(:ticket, priority: :medium, user: charlie, assignee: alice,  created_at: 7.days.ago) }
    let!(:low_priority) { FactoryBot.create(:ticket, priority: :low, user: charlie, assignee: alice, created_at: 5.days.ago ) }
    let!(:no_priority) { FactoryBot.create(:ticket, priority: :unknown, user: charlie, assignee: alice, created_at: 6.days.ago ) }

    before do
      high_priority.update_attribute(:updated_at, 4.days.ago)
      low_priority.update_attribute(:updated_at, 3.days.ago)
      medium_priority.update_attribute(:updated_at, 2.days.ago)
      no_priority.update_attribute(:updated_at, 1.day.ago)
    end

    it("should allow ordering of tickets") do
      sign_in(alice)
      ticket.destroy
      get(:index, :params => ({ :order => :priority }))
      expect(assigns(:tickets)).to eq([high_priority, medium_priority, low_priority, no_priority])
    end

    it("should creation date ordering of tickets") do
      sign_in(alice)
      ticket.destroy
      get(:index, :params => ({ :order => :created_at }))
      expect(assigns(:tickets)).to eq([low_priority, no_priority, medium_priority, high_priority])
    end

    it("should respond with a default ordering of the last updated at if no order param is provided") do
      sign_in(alice)
      ticket.destroy
      get(:index)
      expect(assigns(:tickets)).to eq([no_priority, medium_priority, low_priority, high_priority])
    end
  end

  it("should email assignee if ticket is assigned by somebody else") do
    sign_in(alice)
    expect do
      put(:update, :params => ({ :id => ticket.id, :ticket => ({ :assignee_id => charlie.id }) }))
      assert_redirected_to(ticket_path(ticket))
    end.to(change { ActionMailer::Base.deliveries.size })
    expect(ActionMailer::Base.deliveries.last.subject).to(match("Ticket assigned to you"))
  end

  it("should email assignee if status of ticket is changed by somebody else") do
    sign_in(charlie)
    expect do
      put(:update, :params => ({ :id => ticket.id, :ticket => ({ :status => "closed" }) }))
      assert_redirected_to(ticket_path(ticket))
    end.to(change { ActionMailer::Base.deliveries.size })
    expect(ActionMailer::Base.deliveries.last.subject).to(match("Ticket status changed to closed"))
  end

  it("should email assignee if priority of ticket is changed by somebody else") do
    sign_in(charlie)
    expect do
      put(:update, :params => ({ :id => ticket.id, :ticket => ({ :priority => "high" }) }))
      assert_redirected_to(ticket_path(ticket))
    end.to(change { ActionMailer::Base.deliveries.size })
    expect(ActionMailer::Base.deliveries.last.subject).to(match("Ticket priority changed to high"))
  end

  it("should not email assignee if ticket is assigned by himself") do
    sign_in(charlie)
    expect do
      put(:update, :params => ({ :id => ticket.id, :ticket => ({ :assignee_id => charlie.id }) }))
      assert_redirected_to(ticket_path(ticket))
    end.to_not(change { ActionMailer::Base.deliveries.size })
  end

  it("should not email assignee if status of ticket is changed by himself") do
    sign_in(alice)
    expect do
      put(:update, :params => ({ :id => ticket.id, :ticket => ({ :status => "closed" }) }))
      assert_redirected_to(ticket_path(ticket))
    end.to_not(change { ActionMailer::Base.deliveries.size })
  end

  it("should not email assignee if priority of ticket is changed by himself") do
    sign_in(alice)
    expect do
      put(:update, :params => ({ :id => ticket.id, :ticket => ({ :priority => "high" }) }))
      assert_redirected_to(ticket_path(ticket))
    end.to_not(change { ActionMailer::Base.deliveries.size })
  end

  it("should not show duplicate tickets to agents") do
    sign_in(alice)
    ticket.labels.create!(:name => "test1")
    ticket.labels.create!(:name => "test2")
    get(:index)
    expect(response).to have_http_status(:success)
    tickets = assigns(:tickets)
    expect(tickets.pluck(:id)).to(eq(tickets.pluck(:id).uniq))
  end

  it("should not show duplicate tickets to customers") do
    sign_in(charlie)
    label = ticket.labels.create!(:name => "test1")
    (charlie.labels << label)
    label = ticket.labels.create!(:name => "test2")
    (charlie.labels << label)
    get(:index)
    expect(response).to have_http_status(:success)
    tickets = assigns(:tickets)
    expect(tickets.pluck(:id)).to(eq(tickets.pluck(:id).uniq))
  end

  it("should not notify when a bounce message is received") do
    email = file_fixture('ticket_mailer/bounce').read
    expect do
      expect do
        post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => email, :format => :json }))
        expect(response).to have_http_status(:success)
      end.to(change { Ticket.count })
    end.to_not(change { ActionMailer::Base.deliveries.size })
  end

  it("should not save invalid") do
    email = file_fixture('ticket_mailer/invalid').read
    expect do
      expect do
        post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => email, :format => :json }))
        assert_response(:unprocessable_entity)
      end.to_not(change { Ticket.count })
    end.to_not(change { ActionMailer::Base.deliveries.size })
  end

  it("should get new ticket form in correct language") do
    I18n.locale = :nl
    get(:new)
    expect(response).to have_http_status(:success)
    refute_match(I18n.t("activerecord.attributes.ticket.from", :locale => :nl), response.body)
  end

  it("should get raw message") do
    sign_in(alice)
    ticket.raw_message = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'ticket_mailer', 'simple'))
    ticket.save!
    ticket.reload
    get(:show, :params => ({ :id => ticket.id, :format => :eml }))
    expect(response).to have_http_status(:success)
  end

  it("should mark new ticket from MTA as unread for all users") do
    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
      ticket = Ticket.last
      expect(ticket.unread_users.nil?).to_not(be_nil)
    end.to(change { Ticket.count })
  end

  it("should mark new ticket as unread for all users") do
    expect do
      post(:create, :params => ({ :ticket => ({ :from => "test@test.nl", :content => ticket.content, :subject => ticket.subject }) }))
      expect(response).to have_http_status(:success)
      ticket = Ticket.last
      expect(ticket.unread_users.nil?).to_not(be_nil)
    end.to(change { Ticket.count })
  end

  it("should mark new ticket as unread for all users when posted from MTA") do
    expect do
      post(:create, :params => ({ :hook => "post-mail", :mail_key => (TicketsController::MAIL_KEY), :message => (@simple_email), :format => :json }))
      expect(response).to have_http_status(:success)
      ticket = Ticket.last
      expect(ticket.unread_users).to_not(be_nil)
    end.to(change { Ticket.count })
  end

  it("should mark ticket as read when clicked") do
    user = alice
    sign_in(user)
    ticket = Ticket.last
    (user.unread_tickets << ticket)
    expect do
      expect(ticket.unread_users).to_not(be_nil)
      expect(user.unread_tickets).to_not(be_nil)
      get(:show, :params => ({ :id => ticket.id }))
      expect(response).to have_http_status(:success)
      expect(ticket.unread_users).not_to include(user)
    end.to(change { Ticket.last.unread_users.count }.by(-1))
  end
end
