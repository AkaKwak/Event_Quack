# db/seeds.rb

# Effacer les anciens enregistrements
Event.delete_all

# Récupérer les utilisateurs existants
users = User.all

# Vérifier que nous avons des utilisateurs
if users.empty?
  puts "Aucun utilisateur trouvé. Assurez-vous d'avoir des utilisateurs dans la base de données."
else
  # Créer des événements passés
  3.times do
    start_date = Time.current - rand(1..10).days
    end_date = start_date + rand(30..180).minutes # Durée aléatoire entre 30 et 180 minutes
    Event.create!(
      title: Faker::Music.band,
      description: Faker::Lorem.characters(number: 20),
      location: Faker::Address.city,
      price: rand(10..50),
      start_date: start_date,
      end_date: end_date,
      user: users.sample # Assigne un utilisateur aléatoire
    )
  end

  # Créer des événements futurs
  12.times do
    start_date = Time.current + rand(1..10).days
    end_date = start_date + rand(30..180).minutes # Durée aléatoire entre 30 et 180 minutes
    Event.create!(
      title: Faker::Concert.name,
      description: Faker::Lorem.characters(number: 20),
      location: Faker::Address.city,
      price: rand(10..50),
      start_date: start_date,
      end_date: end_date,
      user: users.sample # Assigne un utilisateur aléatoire
    )
  end

  puts "Création de #{Event.count} événements."
end
