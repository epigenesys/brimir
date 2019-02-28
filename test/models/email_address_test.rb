# == Schema Information
#
# Table name: email_addresses
#
#  id                 :integer          not null, primary key
#  default            :boolean          default(FALSE)
#  email              :string
#  name               :string
#  verification_token :string
#  created_at         :datetime
#  updated_at         :datetime
#

require 'test_helper'

class EmailAddressTest < ActiveSupport::TestCase

  test 'should use correct default address' do
    Tenant.current_domain = Tenant.first.domain

    assert_equal 'outgoing@support.bla', EmailAddress.default_email

    EmailAddress.destroy_all

    assert_equal 'support@test.host', EmailAddress.default_email
  end

end
