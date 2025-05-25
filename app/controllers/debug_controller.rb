class DebugController < ApplicationController
  def champions
    @timezone = Time.current.in_time_zone('Europe/Zurich')
    
    # Heute
    @today_start = @timezone.beginning_of_day
    @today_end = @timezone
    @today_donations = donations_for_period(@today_start, @today_end)
    
    # Gestern
    @yesterday_start = 1.day.ago.in_time_zone('Europe/Zurich').beginning_of_day
    @yesterday_end = 1.day.ago.in_time_zone('Europe/Zurich').end_of_day
    @yesterday_donations = donations_for_period(@yesterday_start, @yesterday_end)
    
    render json: {
      current_time: @timezone.strftime('%d.%m.%Y %H:%M %Z'),
      today: {
        start: @today_start.strftime('%d.%m.%Y %H:%M'),
        end: @today_end.strftime('%d.%m.%Y %H:%M'),
        donations: @today_donations.map { |d| 
          { 
            username: d.member_username,
            occurred_at: d.occurred_at.in_time_zone('Europe/Zurich').strftime('%d.%m.%Y %H:%M'),
            item: d.item_name,
            quantity: d.quantity,
            points: d.calculated_points
          }
        }
      },
      yesterday: {
        start: @yesterday_start.strftime('%d.%m.%Y %H:%M'),
        end: @yesterday_end.strftime('%d.%m.%Y %H:%M'),
        donations: @yesterday_donations.map { |d| 
          { 
            username: d.member_username,
            occurred_at: d.occurred_at.in_time_zone('Europe/Zurich').strftime('%d.%m.%Y %H:%M'),
            item: d.item_name,
            quantity: d.quantity,
            points: d.calculated_points
          }
        }
      }
    }
  end

  private
  
  def donations_for_period(start_date, end_date)
    Donation.where(
      transaction_type: 'deposit',
      excluded: [false, nil],
      occurred_at: start_date.utc..end_date.utc
    ).includes(:member).order(:occurred_at)
  end
end