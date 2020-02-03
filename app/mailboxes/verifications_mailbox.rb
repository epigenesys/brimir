class VerificationsMailbox < ApplicationMailbox
  def process
    to_verify = EmailAddress.where.not(verification_token: nil)

    if to_verify.count > 0
      to_verify.each do |email_address|
        if email['X-Brimir-Verification'].to_s == email_address.verification_token
          email_address.verification_token = nil
          email_address.save!

          return true
        end
      end
    end

    return false
  end
end
