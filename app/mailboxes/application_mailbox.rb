class ApplicationMailbox < ActionMailbox::Base
  routing :all => :tickets
end