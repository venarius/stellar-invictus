Spaceship.all.each do |ship|
   main_amount = 0
   utility_amount = 0
   
   ship.get_equipped_equipment.each do |equipment|
      main_amount = main_amount + 1 if equipment.get_attribute('slot_type') == "main"
      utility_amount = utility_amount + 1 if equipment.get_attribute('slot_type') == "utility"
   end
   
   if main_amount > Spaceship.ship_variables[ship.name]['main_equipment_slots']
       ship.get_equipped_equipment.each do |equipment|
           if equipment.get_attribute('slot_type') == "main" and main_amount > Spaceship.ship_variables[ship.name]['main_equipment_slots']
              equipment.update_columns(equipped: false)
              main_amount = main_amount - 1
           end
       end
   end
   
   if utility_amount > Spaceship.ship_variables[ship.name]['utility_equipment_slots']
       ship.get_equipped_equipment.each do |equipment|
           if equipment.get_attribute('slot_type') == "utility" and utility_amount > Spaceship.ship_variables[ship.name]['utility_equipment_slots']
              equipment.update_columns(equipped: false)
              utility_amount = utility_amount - 1
           end
       end
   end
end