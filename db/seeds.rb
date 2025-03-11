# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

# Chemin du fichier pour stocker les utilisateurs générés
users_file = Rails.root.join("fake_users.txt")

# Réinitialiser le fichier avant d'écrire dedans
File.open(users_file, "w") { |file| file.puts "📜 Liste des utilisateurs générés :\n" }

puts "🛑 Suppression des anciennes données..."
Cart.destroy_all
Order.destroy_all
Plant.destroy_all
User.destroy_all

admins = []
non_admins = []

puts "👤 Création de 3 administrateurs..."
3.times do |i|
  user = User.create!(
    email: "admin#{i+1}@example.com",
    password: "password",
    password_confirmation: "password",
    admin: true
  )
  admins << user
end

puts "👥 Création de 19 utilisateurs non-admin..."
19.times do
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: "password",
    password_confirmation: "password",
    admin: false
  )
  non_admins << user
end

# Écriture des utilisateurs dans le fichier
File.open(users_file, "a") do |file|
  file.puts "\n🔹 **Admins** 🔹"
  admins.each { |admin| file.puts "  • #{admin.email} | password" }

  file.puts "\n🔸 **Utilisateurs normaux** 🔸"
  non_admins.each { |user| file.puts "  • #{user.email} | password" }
end

puts "📋 Liste des 3 Admins générés :"
admins.first(3).each { |admin| puts "  • #{admin.email}" }

puts "📋 Liste des 3 Non-admin générés :"
non_admins.first(3).each { |user| puts "  • #{user.email}" }

puts "🌱 Création des plantes..."
plants = []
10.times do
  plants << Plant.create!(
    name: Faker::Lorem.words(number: 2).join(" "),
    price: rand(5..50),
    description: Faker::Lorem.sentence(word_count: 10),
    stock: rand(5..30)
  )
end

puts "🛒 Remplissage des paniers..."
User.all.each do |user|
  rand(1..3).times do
    plant = plants.sample
    quantity = rand(1..5)
    next if plant.stock < quantity

    Cart.create!(user: user, plant: plant, quantity: quantity)
  end
end

puts "📦 Création des commandes..."
User.all.each do |user|
  cart_items = user.carts.includes(:plant)
  next if cart_items.empty?

  total_price = cart_items.sum { |item| item.plant.price * item.quantity }
  Order.create!(
    user: user,
    total_price: total_price,
    status: %w[confirmed pending shipped delivered].sample
  )

  cart_items.each { |item| item.plant.update(stock: item.plant.stock - item.quantity) }
  cart_items.destroy_all
end

puts "✅ Seed terminée avec succès ! 🌿"
puts "📂 Les utilisateurs générés ont été enregistrés dans `fake_users.txt`."
