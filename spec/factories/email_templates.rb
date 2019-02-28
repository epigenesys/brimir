# == Schema Information
#
# Table name: email_templates
#
#  id         :integer          not null, primary key
#  draft      :boolean          default(TRUE), not null
#  kind       :integer          not null
#  message    :text
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :active_user_welcome, class: EmailTemplate do
    name { 'Default user welcome' }
    kind { EmailTemplate.kinds[:user_welcome] }
    message  { 'Dear [name], First of all we like to thank you for choosing BRIMIR! Your account for the open source ticket system BRIMIR has just been created! To sign in you will need the following information. E-mail [email] Password [password] With kind regards, Webmaster [domain]' }
    created_at { Time.now }
    updated_at { Time.now }
    draft { false }
  end
  
  factory :active_ticket_received, class: EmailTemplate do
    name { 'Default ticket received' }
    message  { 'Dear [name], On [created_at], you wrote: [content] You are receiving this email to let you know that your ticket with the number [id], has been received. With kind regards, Webmaster [domain] *** This is an automatically generated email, please do not reply ***' }
    kind { EmailTemplate.kinds[:ticket_received] }
    created_at { Time.now }
    updated_at { Time.now }
    draft { false }
  end
  
  factory :inactive_ticket_received, class: EmailTemplate do
    name { 'Default ticket received' }
    message  { 'Dear [name], On [created_at], you wrote: [content] You are receiving this email to let you know that your ticket with the number [id], has been received. With kind regards, Webmaster [domain] *** This is an automatically generated email, please do not reply ***' }
    kind { EmailTemplate.kinds[:ticket_received] }
    created_at { Time.now }
    updated_at { Time.now }
    draft { true }
  end
  
  factory :inactive_user_welcome, class: EmailTemplate do
    name { 'Default user welcome' }
    kind { EmailTemplate.kinds[:user_welcome] }
    message  { 'Dear [name], First of all we like to thank you for choosing BRIMIR! Your account for the open source ticket system BRIMIR has just been created! To sign in you will need the following information. E-mail [email] Password [password] With kind regards, Webmaster [domain]' }
    created_at { Time.now }
    updated_at { Time.now }
    draft { true }
  end
  
  factory :canned_reply, class: EmailTemplate do
    name { 'Canned response' }
    kind { EmailTemplate.kinds[:canned_reply] }
    message  { 'Been there, done that.' }
    created_at { Time.now }
    updated_at { Time.now }
    draft { false }
  end
end
