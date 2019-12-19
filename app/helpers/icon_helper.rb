module IconHelper
  
  def status_icon(status, options = {assigned_to_me: false})
    content_tag(:span, '', class: status_icon_class(status, options)).html_safe
  end
  
  def status_icon_class(status, options = {assigned_to_me: false})
    case status
    when 'open'
      if options[:assigned_to_me]
        "fa fa-fw fa-user"
      else
        "fa fa-fw fa-inbox"
      end
    when 'waiting'
      "fa fa-fw fa-clock"
    when 'closed'
      "fa fa-fw fa-check"
    when 'deleted'
      "fa fa-fw fa-trash"
    end
  end
  
end