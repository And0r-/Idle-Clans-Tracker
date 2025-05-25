namespace :donations do
  desc "Recalculate all donation points"
  task recalculate_points: :environment do
    puts "🔄 Recalculating donation points..."
    
    updated_count = 0
    Donation.includes(:member).find_each do |donation|
      old_points = donation.points_value
      new_points = ItemValue.points_for(donation.item_name, donation.quantity)
      
      if old_points != new_points
        donation.update!(points_value: new_points)
        puts "Updated: #{donation.member.username} - #{donation.item_name} (#{old_points} -> #{new_points})"
        updated_count += 1
      end
    end
    
    puts "🔄 Recalculating member total points..."
    Member.find_each(&:update_total_points!)
    
    puts "✅ Updated #{updated_count} donations!"
  end
end