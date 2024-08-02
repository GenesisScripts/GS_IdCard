return {
    ID_show_time = 5000, -- Time badge should display
    
    ID_item = "state_id",  -- What is your ID item name 

     -- Coordinates for the ox_target box zone
     ox_target_coords = { x = 440.6275, y = -981.0618, z = 30.6896 },
     ox_target_size = { x = 6, y = 6, z = 6 },
     ox_target_rotation = 0,
     ox_target_debug = false,

   --what you want your licences to be called on the ID
    car_lic = "Car",
    bike_lic = "Bike",
    truck_lic = "Truck",

    locales = {
        department_name = 'San andreas DMV licence appointments',
        progress_label = 'Showing Licence',
        ad_input_title = 'Change Address',
        ad_input_text = 'Address:',
        input_title = 'Licence Photo',
        input_text = 'Licence Photo URL',
        no_photo = 'You didnt enter a photo',
        no_ad = 'You didnt enter a address',
        update_badge_photo_success = 'Successfully updated your ID Photo!',
        update_address_success = 'Successfully updated your Address!'
    },

    target ={
        ox_target_coords = { x = 440.6275, y = -981.0618, z = 30.6896 },
        ox_target_rotation = 0,
        ox_target_debug = false,
    }
 }