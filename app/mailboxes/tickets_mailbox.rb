class TicketsMailbox < ApplicationMailbox
  def process
    if VerificationMailbox.new(mail).process
      return
    end

    content = ''

    if mail.multipart?
      if mail.html_part
        content = normalize_body(mail.html_part, mail.html_part.charset)
        content_type = 'html'
      elsif mail.text_part
        content = normalize_body(mail.text_part, mail.text_part.charset)
        content_type = 'text'
      else
        content = normalize_body(mail.parts[0], mail.parts[0].charset)
        content_type = 'html'
      end
    else
      if mail.charset
        content = normalize_body(mail, mail.charset)
      else
        content = encode(mail.body.decoded)
      end
      if mail.content_type.include? 'html'
        content_type = 'html'
      else
        content_type = 'text'
      end
    end

    if mail.charset
      subject = encode(mail.subject.to_s.force_encoding(mail.charset))
    else
      subject = mail.subject.to_s.encode('UTF-8')
    end

    if mail.in_reply_to
      # is this a reply to a ticket or to another reply?
      response_to = Ticket.find_by_message_id(mail.in_reply_to)

      if !response_to

        response_to = Reply.find_by_message_id(mail.in_reply_to)

        if response_to
          ticket = response_to.ticket
        else
          # we create a new ticket further below in this case
        end
      else
        ticket = response_to
      end
    end

    from_address = mail.from.first
    # yes this can get really long...
    to_addresses = mail.to.join ',' unless mail.to.nil?
    cc_addresses = mail.cc.join ',' unless mail.cc.nil?
    unless mail.reply_to.blank?
      if mail.reply_to.is_a? Array
        from_address = mail.reply_to.first
      else
        from_address = mail.reply_to
      end
    end

    if response_to
      # reopen ticket
      ticket.status = :open
      ticket.save

      # add reply
      incoming = Reply.create({
        content: content,
        ticket_id: ticket.id,
        from: from_address,
        message_id: mail.message_id,
        content_type: content_type,
        raw_message: StringIO.new(mail.to_s),
        reply_to_id: response_to.try(:id),
        reply_to_type: response_to.try(:class).try(:name)
      })

    else

      to_email_address = EmailAddress.find_first_verified_email(
          mail.to.to_a + mail.cc.to_a + mail.bcc.to_a)

      # add new ticket
      ticket = Ticket.create({
        from: from_address,
        orig_to: to_addresses,
        orig_cc: cc_addresses,
        subject: subject,
        content: content,
        message_id: mail.message_id,
        content_type: content_type,
        to_email_address: to_email_address,
        raw_message: StringIO.new(mail.to_s),
        unread_users: User.where(agent: true),
        created_at: (mail.date || Time.zone.now)
      })

      incoming = ticket

    end

    if mail.has_attachments?

      mail.attachments.each do |attachment|

        file = StringIO.new(attachment.decoded)

        # add needed fields for paperclip
        file.class.class_eval {
            attr_accessor :original_filename, :content_type
        }

        file.original_filename = attachment.filename
        file.content_type = attachment.mime_type

        # store content_id with stripped off '<' and '>'
        content_id = nil
        unless attachment.content_id.blank?
          content_id = attachment.content_id[1..-2]
          content_id = nil unless incoming.content.include?(content_id)
        end

        attachment = incoming.attachments.new
        attachment.content_id = content_id
        begin
          attachment.file = file
          attachment.save!
        rescue
          file.rewind
          attachment.disable_thumbnail_generation = true
          attachment.file = file
          attachment.save!
        end
      end
    end

    if bounced?(mail)
      nil
    else
      incoming
    end
  end

  private
    def bounced?(mail)
      return true if mail.bounced?
      return true if !mail.header['Return-Path'].nil? && mail['Return-Path'].value == ''

      false
    end

    def encode(string)
      string.encode('UTF-8', invalid: :replace, undef: :replace)
    end

    def normalize_body(part, charset)
      # some mail clients apparently send wrong charsets
      charset = 'utf-8' if charset == 'utf8'
      encode(part.body.decoded.force_encoding(charset))
    end
end
