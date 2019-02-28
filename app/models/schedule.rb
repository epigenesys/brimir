# == Schema Information
#
# Table name: schedules
#
#  id         :integer          not null, primary key
#  end        :datetime
#  friday     :boolean          default(TRUE), not null
#  monday     :boolean          default(TRUE), not null
#  saturday   :boolean          default(FALSE), not null
#  start      :datetime
#  sunday     :boolean          default(FALSE), not null
#  thursday   :boolean          default(TRUE), not null
#  tuesday    :boolean          default(TRUE), not null
#  wednesday  :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Schedule < ApplicationRecord

  has_one :user, dependent: :destroy

  def is_during_work?(time_in_zone_for_user)
    user_wday = time_in_zone_for_user.wday
    user_hour = time_in_zone_for_user.hour
    return false unless is_on_day?(user_wday)
    if user_hour <= self.end.hour && user_hour >= self.start.hour
      # if true we need to check minutes
      if user_hour == self.end.hour 
        return false if time_in_zone_for_user.min > 0
      end
      return true
    end
    return false
  end

  def is_on_day?(weekday)
    case weekday
    when 0
      sunday?
    when 1
      monday?
    when 2
      tuesday?
    when 3
      wednesday?
    when 4
      thursday?
    when 5
      friday?
    when 6
      saturday?
    else
      false
    end
  end

  def start=(attribute)
    time = Time.find_zone('UTC').parse(attribute)
    write_attribute(:start, time)
  end

  def end=(attribute)
    time = Time.find_zone('UTC').parse(attribute)
    write_attribute(:end, time)
  end

end
