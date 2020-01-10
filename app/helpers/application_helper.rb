# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi https://ivaldi.nl/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# helpers used system wide
module ApplicationHelper
  def active_elem_if(elem, condition, attributes = {}, &block)
    if condition
      # define class as empty string when no class given
      attributes[:class] ||= ''
      # add 'active' class
      attributes[:class] += ' active'
    end

    # return the content tag with possible active class
    content_tag(elem, attributes, &block)
  end

  # change the default link renderer for will_paginate
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge renderer: WillPaginate::ActionView::BootstrapLinkRenderer
    end
    super(*[collection_or_options, options].compact)
  end

  def tabindex
    @tabindex ||= 0
    @tabindex += 1
  end

  # Tag to link the custom stylesheet if enabled and either set by application
  # setting (higher priority) or tenant setting (lower priority)
  def custom_stylesheet_link_tag
    if AppSettings.enable_custom_stylesheet
      if url = AppSettings.custom_stylesheet_url || Tenant.current_tenant.stylesheet_url
        stylesheet_link_tag url
      end
    end
  end

  # Tag to include the custom javascript if enabled and either set by application
  # setting (higher priority) or tenant setting (lower priority)
  def custom_javascript_include_tag
    if AppSettings.enable_custom_javascript
      if url = AppSettings.custom_javascript_url || Tenant.current_tenant.javascript_url
        javascript_include_tag url
      end
    end
  end

  def fa_icon(names, original_options = {})
    options = original_options.deep_dup

    icon_style = options.has_key?(:style) ? options.delete(:style) : 'fas'
    icon_size = icon_size(options.delete(:size))
    fa_five_classes = [icon_style, icon_size].compact

    classes = fa_five_classes
    classes.concat icon_names(names)
    classes.concat Array(options.delete(:class))
    text = options.delete(:text)
    right_icon = options.delete(:right)
    icon = content_tag(:i, nil, options.merge(:class => classes))
    icon_join(icon, text, right_icon)
  end

  def icon_size(icon_size)
    if icon_size.present?
      icon_size.start_with?("fa-") ? icon_size : "fa-#{icon_size}"
    end
  end

  def icon_names(names = [])
    array_value(names).map { |n| "fa-#{n}" }
  end

  def icon_join(icon, text, reverse_order = false)
    return icon if text.blank?
    elements = [icon, ERB::Util.html_escape(text)]
    elements.reverse! if reverse_order
    safe_join(elements, " ")
  end

  def array_value(value = [])
    value.is_a?(Array) ? value : value.to_s.split(/\s+/)
  end
end
