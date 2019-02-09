# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Helpers
helix_lorem = "Even the most powerful pirate forces need a good infrastructure and networks. Because of this, the Helix Collective was founded by four well known
                pirate leaders. Their common goal is the liberation of space as we know it. To reach their goal, most members of the Helix Collective stop at nothing.
                Many people leave their families and homes behind in hope to become the next rich but also feared person. Due to their aggresive behavior, the Helix Collective
                built some of the greatest Warships out there. Featuring a whole lot of weapon slots and a from the ground up rebuilt targeting processor, these machines shine with their raw gunpower."
caldarius_lorem = "The Caldarius Federation consists of 21 self-governing territories around the universe. Whilst being able to move and act freely, their
                    guiding principle always was impartiality. They have never been in a war with external parties. Due to their neutrality, the Caldarius Federation
                    steadily improved their defense capabilites in case of trouble. Their ships are primarily known for their especially reinforced hulls and their
                    massive shields that can stand a large enemy fleets."
core_lorem = "Built from the ground up with freedom of speech in mind, the Core Republic is now a well known part of the universe we know. There have always 
              been some civil wars due to different opinions about drugs and weapons in the past but the Core Republic always grows stronger with every one of them.<br>Since 
              everyone is able to choose their own path of career, most people became Freighter-Pilots. After decades of researching on how to increase the storage capacity of ships even more,
              they have been able to celebrate their first breakthroughs not very long ago."

################################
#          Galaxy              #
################################
#      See db/diagram          #
################################

# Helpful for Factions https://www.reddit.com/r/worldbuilding/comments/3ni531/how_would_you_create_nongeneric_scifi_factions/
# https://www.youtube.com/watch?v=ZYiMurIw-MA

# Factions
faction1 = Faction.find_or_create_by(id: 1, name: 'Helix Collective', description: helix_lorem)
faction2 = Faction.find_or_create_by(id: 2, name: 'Caldarius Federation', description: caldarius_lorem)
faction3 = Faction.find_or_create_by(id: 3, name: 'Core Republic', description: core_lorem)

# Systems

# low-sec
re_fii = System.find_or_create_by(name: 'RE-FII', security_status: 'low')
cr_181 = System.find_or_create_by(name: 'CR-181', security_status: 'low')
ki_233 = System.find_or_create_by(name: 'KI-233', security_status: 'low')
zu_6tt = System.find_or_create_by(name: 'ZU-6TT', security_status: 'low')
tz_877 = System.find_or_create_by(name: 'TZ-877', security_status: 'low')
vb_233 = System.find_or_create_by(name: 'VB-233', security_status: 'low')
ke_35f = System.find_or_create_by(name: 'KE-35F', security_status: 'low')
sr_378 = System.find_or_create_by(name: 'SR-378', security_status: 'low')
kq_43r = System.find_or_create_by(name: 'KQ-43R', security_status: 'low')

tk_63r = System.find_or_create_by(name: 'TK-63R', security_status: 'low')
zz_23f = System.find_or_create_by(name: 'ZZ-23F', security_status: 'low')
fh_232 = System.find_or_create_by(name: 'FH-232', security_status: 'low')
wq_f65 = System.find_or_create_by(name: 'WQ-F65', security_status: 'low')
ft_r3t = System.find_or_create_by(name: 'FT-R3T', security_status: 'low')
nf_z66 = System.find_or_create_by(name: 'NF-Z66', security_status: 'low')
uc_233 = System.find_or_create_by(name: 'UC-233', security_status: 'low')

# mid-sec
talos = System.find_or_create_by(name: 'Talos', security_status: 'medium')
decon = System.find_or_create_by(name: 'Decon', security_status: 'medium')
urus = System.find_or_create_by(name: 'Urus', security_status: 'medium')
zimse = System.find_or_create_by(name: 'Zimse', security_status: 'medium')
dresi = System.find_or_create_by(name: 'Dresi', security_status: 'medium')
latos = System.find_or_create_by(name: 'Latos', security_status: 'medium')
alba = System.find_or_create_by(name: 'Alba', security_status: 'medium')
odin = System.find_or_create_by(name: 'Odin', security_status: 'medium')
foves = System.find_or_create_by(name: 'Foves', security_status: 'medium')
finid = System.find_or_create_by(name: 'Finid', security_status: 'medium')
draconis = System.find_or_create_by(name: 'Draconis', security_status: 'medium')
nodens = System.find_or_create_by(name: 'Nodens', security_status: 'medium')
nordar = System.find_or_create_by(name: 'Nordar', security_status: 'medium')

# high-sec
aulin = System.find_or_create_by(name: 'Aulin', security_status: 'high')
hyperion = System.find_or_create_by(name: 'Hyperion', security_status: 'high')
komo = System.find_or_create_by(name: 'Komo', security_status: 'high')
zenais = System.find_or_create_by(name: 'Zenais', security_status: 'high')
perseus = System.find_or_create_by(name: 'Perseus', security_status: 'high')
pherona = System.find_or_create_by(name: 'Pherona', security_status: 'high')
dau = System.find_or_create_by(name: 'Dau', security_status: 'high')
inari = System.find_or_create_by(name: 'Inari', security_status: 'high')
chanoun = System.find_or_create_by(name: 'Chanoun', security_status: 'high')
minin = System.find_or_create_by(name: 'Minin', security_status: 'high')
aunia = System.find_or_create_by(name: 'Aunia', security_status: 'high')
joamma = System.find_or_create_by(name: 'Joamma', security_status: 'high')
belinara = System.find_or_create_by(name: 'Belinara', security_status: 'high')

# Jumpgates 58
jumpgates = [
    ["RE-FII", "CR-181"], ["RE-FII", "VB-233"], ["CR-181", "KI-233"], ["CR-181", "KE-35F"], ["KE-35F", "VB-233"],
    ["KI-233", "SR-378"], ["SR-378", "TZ-877"], ["TZ-877", "ZU-6TT"], ["ZU-6TT", "KQ-43R"], ["SR-378", "KQ-43R"],
    ["VB-233", "Talos"], ["KE-35F", "Urus"], ["KQ-43R", "Dresi"], ["Talos", "Komo"], ["Komo", "Decon"], ["Decon", "Aulin"],
    ["Aulin", "Urus"], ["Urus", "Zimse"], ["Zimse", "Latos"], ["Dresi", "Zimse"], ["Dresi", "Dau"], ["Alba", "Dresi"],
    ["Komo", "Zenais"], ["Zenais", "Hyperion"], ["Hyperion", "Aulin"], ["Perseus", "Pherona"], ["Zenais", "Pherona"], ["Pherona", "Foves"],
    ["Foves", "Odin"], ["Foves", "Finid"], ["Odin", "Latos"], ["Alba", "Odin"], ["Alba", "Dresi"], ["Dau", "Inari"],
    ["Alba", "Inari"], ["Inari", "Joamma"], ["Joamma", "Belinara"], ["Joamma", "Nodens"], ["Belinara", "Finid"],
    ["Finid", "NF-Z66"], ["NF-Z66", "FT-R3T"], ["UC-233", "NF-Z66"], ["UC-233", "FT-R3T"], ["FT-R3T", "WQ-F65"],
    ["FH-232", "WQ-F65"], ["ZZ-23F", "FH-232"], ["TK-63R", "ZZ-23F"], ["Draconis", "Belinara"], ["Draconis", "FH-232"], ["Nodens", "TK-63R"],
    ["Nodens", "Nordar"], ["Nordar", "Aunia"], ["Aunia", "Minin"], ["Chanoun", "Minin"], ["Dau", "Chanoun"], ["Aunia", "Joamma"],
    ["Perseus", "Latos"], ["Chanoun", "Aunia"]
  ]
  
travels = [5, 10, 15, 20]
  
jumpgates.each do |jgs|
  a = Location.find_or_create_by(name: jgs.last, system: System.find_by(name: jgs.first), location_type: 2)
  b = Location.find_or_create_by(name: jgs.first, system: System.find_by(name: jgs.last), location_type: 2)
  Jumpgate.find_or_create_by(origin: a, destination: b, traveltime: travels.sample)
end

# Locations - Asteroid Belts
System.all.each do |sys|
  romans = ["I", "II", "III", "IV", "V", "VI"]
  count = 0
  if sys.locations.where(location_type: 1).empty?
    (rand(0..6)).times do
      Location.find_or_create_by(name: "#{romans[count]}", system: sys, location_type: 1)
      count = count + 1
    end
  end
end

# Locations - Stations ["Industrial Station", "Warfare Plant", "Mining Station", "Research Station"]
Location.find_or_create_by(station_type: 0, system: aunia, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 2, system: aunia, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 3, system: minin, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 1, system: chanoun, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 0, system: dau, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 2, system: inari, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 3, system: inari, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 2, system: joamma, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 0, system: belinara, location_type: 0, faction: faction3)
Location.find_or_create_by(station_type: 2, system: belinara, location_type: 0, faction: faction3)

Location.find_or_create_by(station_type: 0, system: perseus, location_type: 0, faction: faction2)
Location.find_or_create_by(station_type: 2, system: pherona, location_type: 0, faction: faction2)
Location.find_or_create_by(station_type: 3, system: pherona, location_type: 0, faction: faction2)
Location.find_or_create_by(station_type: 1, system: zenais, location_type: 0, faction: faction2)
Location.find_or_create_by(station_type: 0, system: hyperion, location_type: 0, faction: faction2)
Location.find_or_create_by(station_type: 2, system: hyperion, location_type: 0, faction: faction2)
Location.find_or_create_by(station_type: 3, system: aulin, location_type: 0, faction: faction2)
Location.find_or_create_by(station_type: 2, system: aulin, location_type: 0, faction: faction2)
Location.find_or_create_by(station_type: 0, system: komo, location_type: 0, faction: faction2)

Location.find_or_create_by(station_type: 0, system: dresi, location_type: 0, faction: faction1)
Location.find_or_create_by(station_type: 2, system: zimse, location_type: 0, faction: faction1)
Location.find_or_create_by(station_type: 3, system: zimse, location_type: 0, faction: faction1)
Location.find_or_create_by(station_type: 1, system: latos, location_type: 0, faction: faction1)
Location.find_or_create_by(station_type: 0, system: latos, location_type: 0, faction: faction1)
Location.find_or_create_by(station_type: 2, system: urus, location_type: 0, faction: faction1)
Location.find_or_create_by(station_type: 3, system: odin, location_type: 0, faction: faction1)
Location.find_or_create_by(station_type: 2, system: odin, location_type: 0, faction: faction1)
Location.find_or_create_by(station_type: 0, system: alba, location_type: 0, faction: faction1)

# Random Stations
System.all.each do |sys|
  if sys.security_status == 'medium' and sys.locations.where(location_type: 'station').empty?
    rand(1..2).times do
      type = rand(0..3)
      Location.find_or_create_by(station_type: type, system: sys, location_type: 0) if sys.locations.where(station_type: type).empty?
    end
  end
end

# Chat Rooms for Global and Locations
ChatRoom.create(chatroom_type: 'global', title: 'Global')

# Newbie Room
ChatRoom.create(chatroom_type: 'custom', title: 'Rookies', identifier: 'ROOKIES')

# Recruitment Room
ChatRoom.create(chatroom_type: 'custom', title: 'Recruiting', identifier: 'RECRUIT')