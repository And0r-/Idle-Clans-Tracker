# app/models/member.rb
class Member < ApplicationRecord
  self.primary_key = :username
  
  has_many :donations, foreign_key: :member_username, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true
  
  # Timezone für alle Berechnungen
  TIMEZONE = 'Europe/Zurich'.freeze
  
  # Live-Berechnung der Gesamtpunkte
  def total_points
    donations.counted
             .where(transaction_type: 'deposit')
             .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
             .sum('donations.quantity * COALESCE(item_values.points_per_unit, 0)')
  end
  
  # Punkte für einen bestimmten Zeitraum
  def points_for_period(start_time, end_time)
    # Sicherstellen dass wir UTC-Zeiten für die DB haben
    start_utc = start_time.is_a?(String) ? Time.zone.parse(start_time).utc : start_time.utc
    end_utc = end_time.is_a?(String) ? Time.zone.parse(end_time).utc : end_time.utc
    
    donations.counted
             .where(transaction_type: 'deposit', occurred_at: start_utc..end_utc)
             .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
             .sum('donations.quantity * COALESCE(item_values.points_per_unit, 0)')
  end
  
  # Punkte für heute (Zürich-Zeit)
  def points_today
    zurich_now = Time.current.in_time_zone(TIMEZONE)
    today_start = zurich_now.beginning_of_day
    points_for_period(today_start, zurich_now)
  end
  
  # Punkte für gestern (Zürich-Zeit)
  def points_yesterday
    zurich_now = Time.current.in_time_zone(TIMEZONE)
    yesterday_start = zurich_now.ago(1.day).beginning_of_day
    yesterday_end = zurich_now.ago(1.day).end_of_day
    points_for_period(yesterday_start, yesterday_end)
  end
  
  # Punkte für diese Woche (Zürich-Zeit)
  def points_this_week
    zurich_now = Time.current.in_time_zone(TIMEZONE)
    week_start = zurich_now.beginning_of_week(:sunday)
    points_for_period(week_start, zurich_now)
  end
  
  # Class Methods für Champions
  class << self
    def champion_for_period(period)
      case period.to_sym
      when :all
        champion_all_time
      when :today
        champion_today
      when :yesterday
        champion_yesterday
      when :this_week
        champion_this_week
      when :last_week
        champion_last_week
      else
        nil
      end
    end
    
    private
    
    def champion_all_time
      joins(:donations)
        .where(donations: { transaction_type: 'deposit', excluded: [false, nil] })
        .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
        .group("members.username")
        .select("members.username, SUM(donations.quantity * COALESCE(item_values.points_per_unit, 0)) as total_points")
        .order("total_points DESC")
        .first
    end
    
    def champion_today
      zurich_now = Time.current.in_time_zone(TIMEZONE)
      today_start = zurich_now.beginning_of_day
      champion_for_time_range(today_start, zurich_now, "heute")
    end
    
    def champion_yesterday
      zurich_now = Time.current.in_time_zone(TIMEZONE)
      yesterday_start = zurich_now.ago(1.day).beginning_of_day
      yesterday_end = zurich_now.ago(1.day).end_of_day
      champion_for_time_range(yesterday_start, yesterday_end, "gestern")
    end
    
    def champion_this_week
      zurich_now = Time.current.in_time_zone(TIMEZONE)
      week_start = zurich_now.beginning_of_week(:sunday)
      champion_for_time_range(week_start, zurich_now, "diese Woche")
    end
    
    def champion_last_week
      zurich_now = Time.current.in_time_zone(TIMEZONE)
      last_week_start = zurich_now.ago(1.week).beginning_of_week(:sunday)
      last_week_end = zurich_now.ago(1.week).end_of_week(:saturday)
      champion_for_time_range(last_week_start, last_week_end, "letzte Woche")
    end
    
    def champion_for_time_range(start_time, end_time, label)
      start_utc = start_time.utc
      end_utc = end_time.utc
      
      Rails.logger.info "🔍 Champion #{label}: #{start_time.strftime('%d.%m.%Y %H:%M')} bis #{end_time.strftime('%d.%m.%Y %H:%M')} (Zürich)"
      Rails.logger.info "🔍 Champion #{label} UTC: #{start_utc.strftime('%d.%m.%Y %H:%M')} bis #{end_utc.strftime('%d.%m.%Y %H:%M')}"
      
      champion = joins(:donations)
                  .where(donations: { 
                    transaction_type: 'deposit', 
                    excluded: [false, nil],
                    occurred_at: start_utc..end_utc
                  })
                  .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
                  .group("members.username")
                  .select("members.username, SUM(donations.quantity * COALESCE(item_values.points_per_unit, 0)) as period_points")
                  .order("period_points DESC")
                  .first
      
      if champion
        Rails.logger.info "🏆 Champion #{label}: #{champion.username} mit #{champion.period_points} Punkten"
        # Für View-Kompatibilität: period_points als total_points verfügbar machen
        champion.define_singleton_method(:total_points) { period_points }
      else
        Rails.logger.info "❌ Kein Champion für #{label} gefunden"
      end
      
      champion
    end
  end
  
  # Für Abwärtskompatibilität - diese Methode macht jetzt nichts mehr
  def update_total_points!
    # Nichts zu tun - Punkte werden live berechnet
    true
  end
end