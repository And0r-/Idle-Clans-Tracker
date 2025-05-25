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
end