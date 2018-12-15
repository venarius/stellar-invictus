# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Helpers
lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."

################################
#          Galaxy              #
################################
#            20                #
#  Jita ================ Urus  #
#    =                   =     #
#     =                 =      #
#      =               =       #
#   10  =             =  15    #
#        =           =         #
#         =         =          #
#            Talos             #
#                              #
################################

jita = System.find_or_create_by(name: 'Jita', security_status: 'high')
talos = System.find_or_create_by(name: 'Talos', security_status: 'medium')
urus = System.find_or_create_by(name: 'Urus', security_status: 'low')
kerion = System.find_or_create_by(name: 'Kerion', security_status: 'low')

# Factions
faction1 = Faction.find_or_create_by(name: 'Helix Collective', description: lorem)
faction2 = Faction.find_or_create_by(name: 'Caladrius Alliance', description: lorem)
faction3 = Faction.find_or_create_by(name: 'Core Republic', description: lorem)

# Locations - Stations
Location.find_or_create_by(name: 'Factory Plant I', system: jita, location_type: 0, faction: faction1)
Location.find_or_create_by(name: 'Warfare Plant I', system: jita, location_type: 0)
Location.find_or_create_by(name: 'Factory Plant II', system: talos, location_type: 0, faction: faction2)
Location.find_or_create_by(name: 'Tech Plant II', system: urus, location_type: 0, faction: faction3)

# Locations - Asteroid Belts
Location.find_or_create_by(name: 'Asteroid Belt I', system: jita, location_type: 1)

# Locations - Jumpgates
jita_jumpgate_talos = Location.find_or_create_by(name: talos.name, system: jita, location_type: 2)
jita_jumpgate_urus = Location.find_or_create_by(name: urus.name, system: jita, location_type: 2)

talos_jumpgate_urus = Location.find_or_create_by(name: urus.name, system: talos, location_type: 2)
talos_jumpgate_jita = Location.find_or_create_by(name: jita.name, system: talos, location_type: 2)

urus_jumpgate_talos = Location.find_or_create_by(name: talos.name, system: urus, location_type: 2)
urus_jumpgate_jita = Location.find_or_create_by(name: jita.name, system: urus, location_type: 2)

kerion_jumpgate_talos = Location.find_or_create_by(name: talos.name, system: kerion, location_type: 2)
talos_jumpgate_kerion = Location.find_or_create_by(name: kerion.name, system: talos, location_type: 2)

# Jumpgates
Jumpgate.find_or_create_by(origin: jita_jumpgate_talos, destination: talos_jumpgate_jita, traveltime: 10)
Jumpgate.find_or_create_by(origin: jita_jumpgate_urus, destination: urus_jumpgate_jita, traveltime: 20)
Jumpgate.find_or_create_by(origin: urus_jumpgate_talos, destination: talos_jumpgate_urus, traveltime: 15)
Jumpgate.find_or_create_by(origin: kerion_jumpgate_talos, destination: talos_jumpgate_kerion, traveltime: 5)

# Chat Rooms for Global and Locations
ChatRoom.create(chatroom_type: 'global', title: 'Global')