module IconHelper
  
  def status_icon(status, options = {assigned_to_me: false})
    content_tag(:span, '', class: status_icon_class(status, options)).html_safe
  end
  
  def status_icon_class(status, options = {assigned_to_me: false})
    case status
    when 'open'
      if options[:assigned_to_me]
        "user"
      else
        "envelope-open"
      end
    when 'waiting'
      "clock"
    when 'closed'
      "check"
    when 'deleted'
      "trash"
    end
  end
  
end