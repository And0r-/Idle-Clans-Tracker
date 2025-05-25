module ApplicationHelper
  def time_ago_in_seconds(time)
    return "nie" unless time
    
    seconds_ago = (Time.current - time).to_i
    
    case seconds_ago
    when 0..59
      "vor #{seconds_ago} Sekunden"
    when 60..3599
      minutes = seconds_ago / 60
      "vor #{minutes} Minute#{'n' if minutes != 1}"
    when 3600..86399
      hours = seconds_ago / 3600
      "vor #{hours} Stunde#{'n' if hours != 1}"
    else
      days = seconds_ago / 86400
      "vor #{days} Tag#{'en' if days != 1}"
    end
  end
  
  def api_status_badge_class(status, last_fetch_at)
    return 'danger' unless last_fetch_at
    
    seconds_ago = (Time.current - last_fetch_at).to_i
    
    case
    when status&.include?('error')
      'danger'
    when seconds_ago > 120  # Mehr als 2 Minuten
      'warning'
    else
      'success'
    end
  end

# In app/helpers/application_helper.rb ergänzen:
  def period_display_name(period)
    case period
    when :today
      "Heute"
    when :week
      # Aktuelle Woche: Sonntag bis Samstag
      zurich_now = Time.current.in_time_zone('Europe/Zurich')
      week_start = zurich_now.beginning_of_week(:sunday)
      # KORREKTUR: 6 Tage nach Sonntag = Samstag
      week_end = week_start + 6.days
      
      # Deutsche Wochentage
      german_weekdays = {
        'Sunday' => 'So', 'Monday' => 'Mo', 'Tuesday' => 'Di', 
        'Wednesday' => 'Mi', 'Thursday' => 'Do', 'Friday' => 'Fr', 'Saturday' => 'Sa'
      }
      
      start_day_german = german_weekdays[week_start.strftime('%A')]
      end_day_german = german_weekdays[week_end.strftime('%A')]
      
      start_date = week_start.strftime('%d.%m.')
      end_date = week_end.strftime('%d.%m.')
      
      "#{start_day_german} #{start_date} - #{end_day_german} #{end_date}"
    when :all
      "Alle Zeit"
    else
      period.to_s.humanize
    end
  end

  def period_short_name(period)
    case period
    when :today
      "Heute"
    when :week
      "Diese Woche"
    when :all
      "Alle Zeit"
    else
      period.to_s.humanize
    end
  end
end