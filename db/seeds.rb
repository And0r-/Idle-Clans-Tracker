# Standard-Punktwerte für Items
ItemValue.find_or_create_by(item_name: "Gold") do |item|
  item.points_per_unit = 1.0
  item.active = true
end

ItemValue.find_or_create_by(item_name: "Titanium bar") do |item|
  item.points_per_unit = 3350.0
  item.active = true
end

ItemValue.find_or_create_by(item_name: "Magical plank") do |item|
  item.points_per_unit = 264.0
  item.active = true
end

puts "✅ ItemValues erstellt: #{ItemValue.count} Items"