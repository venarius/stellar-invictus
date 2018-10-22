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
talos = System.find_or_create_by(name: 'Talos', security_status: 'mid')
urus = System.find_or_create_by(name: 'Urus', security_status: 'low')

Jumpgate.find_or_create_by(origin: jita, destination: talos, traveltime: 10)
Jumpgate.find_or_create_by(origin: jita, destination: urus, traveltime: 20)
Jumpgate.find_or_create_by(origin: urus, destination: talos, traveltime: 15)

# Factions
Faction.find_or_create_by(name: 'Faction 1', description: lorem)
Faction.find_or_create_by(name: 'Faction 2', description: lorem)
Faction.find_or_create_by(name: 'Faction 3', description: lorem)