# sessions/new.html.erb
<h1>Se Connecter</h1>
<%= form_with url: login_path, scope: :session, local: true do |f| %>
  <div class="mb-3">
    <label class="form-label">Email</label>
    <%= f.text_field :email, class: "form-control" %>
  </div>
  <div class="mb-3">
    <label class="form-label">Mot de passe</label>
    <%= f.password_field :password, class: "form-control" %>
  </div>
  <%= f.submit "Se connecter", class: "btn btn-primary" %>
<% end %>

# admin/plants/index.html.erb
<h1 class="mb-4">Gestion des Plantes (Admin)</h1>

<div class="mb-3">
  <%= link_to "➕ Nouvelle Plante", new_admin_plant_path, class: "btn btn-outline-info" %>
</div>

<table class="table">
  <thead class="table-dark">
    <tr>
      <th>Nom</th>
      <th>Prix</th>
      <th>Stock</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    <% Plant.all.each do |plant| %>
      <tr>
        <td><%= plant.name %></td>
        <td><%= plant.price %> €</td>
        <td><%= plant.stock %></td>
        <td>
          <%= link_to "Modifier", edit_admin_plant_path(plant), class: "btn btn-warning btn-sm me-2" %>
          <%= link_to "Supprimer", admin_plant_path(plant),
                      method: :delete,
                      data: { confirm: "Supprimer cette plante ?" },
                      class: "btn btn-danger btn-sm" %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

# admin/plants/new.html.erb
<h1>Nouvelle Plante (Admin)</h1>
<%= render "admin/plants/form", plant: @plant %>

# admin/plants/destroy.html.erb
<!-- app/views/admin/plants/destroy.html.erb -->
<p>Suppression de la plante...</p>

# admin/plants/create.html.erb
<!-- app/views/admin/plants/create.html.erb -->
<p>Création d’une nouvelle plante en cours...</p>
<!-- Vous pouvez faire un redirect_to via meta refresh ou JS si vous voulez. -->

# admin/plants/edit.html.erb
<h1>Éditer la Plante</h1>
<%= render "admin/plants/form", plant: @plant %>

# admin/plants/update.html.erb
<!-- app/views/admin/plants/update.html.erb -->
<p>Mise à jour de la plante en cours...</p>

# admin/plants/_form.html.erb
<%= form_with model: plant, local: true, url: (plant.persisted? ? admin_plant_path(plant) : admin_plants_path), method: (plant.persisted? ? :patch : :post) do |f| %>
  <% if plant.errors.any? %>
    <div class="alert alert-danger">
      <ul>
      <% plant.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="mb-3">
    <%= f.label :name, "Nom de la plante", class: "form-label" %>
    <%= f.text_field :name, class: "form-control" %>
  </div>

  <div class="mb-3">
    <%= f.label :price, "Prix (€)", class: "form-label" %>
    <%= f.number_field :price, class: "form-control" %>
  </div>

  <div class="mb-3">
    <%= f.label :description, "Description", class: "form-label" %>
    <%= f.text_area :description, rows: 4, class: "form-control" %>
  </div>

  <div class="mb-3">
    <%= f.label :stock, "Stock (unités)", class: "form-label" %>
    <%= f.number_field :stock, class: "form-control" %>
  </div>

  <%= f.submit (plant.persisted? ? "Mettre à jour" : "Créer"), class: "btn btn-primary" %>
<% end %>

# admin/users/index.html.erb
<h1>Gestion des Utilisateurs (Admin)</h1>

<table class="table">
  <thead class="table-dark">
    <tr>
      <th>ID</th>
      <th>Email</th>
      <th>Admin?</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    <% @users.each do |user| %>
      <tr>
        <td><%= user.id %></td>
        <td><%= user.email %></td>
        <td><%= user.admin? ? "Oui" : "Non" %></td>
        <td>
          <%= link_to "Modifier", edit_admin_user_path(user), class: "btn btn-warning btn-sm me-2" %>
          <% unless user == current_user %>
            <%= link_to "Supprimer", admin_user_path(user),
                        method: :delete,
                        data: { confirm: "Supprimer cet utilisateur ?" },
                        class: "btn btn-danger btn-sm" %>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

# admin/users/edit.html.erb
<h1>Modifier l'utilisateur</h1>

<%= form_with model: @user, url: admin_user_path(@user), method: :patch, local: true do |f| %>
  <% if @user.errors.any? %>
    <div class="alert alert-danger">
      <ul>
      <% @user.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="mb-3">
    <%= f.label :email, "Email", class: "form-label" %>
    <%= f.email_field :email, class: "form-control" %>
  </div>

  <div class="mb-3">
    <%= f.label :name, "Nom", class: "form-label" %>
    <%= f.text_field :name, class: "form-control" %>
  </div>

  <div class="mb-3 form-check">
    <%= f.label :admin, "Administrateur ?", class: "form-check-label" %>
    <%= f.check_box :admin, class: "form-check-input" %>
  </div>

  <%= f.submit "Enregistrer", class: "btn btn-primary" %>
<% end %>

# plants/index.html.erb
<h1 class="text-center mb-4">🌿 Liste des Plantes</h1>

<% if user_signed_in? && current_user.admin? %>
  <%= link_to "➕ Nouvelle Plante", new_admin_plant_path, class: "btn btn-info mb-3" %>
<% end %>

<div class="row">
  <% @plants.each do |plant| %>
    <div class="col-md-4">
      <div class="card mb-4 shadow-sm">
        <div class="card-body">
          <h5 class="card-title">
            <%= link_to plant.name, plant_path(plant), class: "text-decoration-none text-dark" %>
          </h5>
          <p class="card-text">
            <strong>Prix :</strong> <%= plant.price %> €<br>
            <strong>Stock :</strong> <%= plant.stock %> unités
          </p>
          <% if user_signed_in? %>
            <%= button_to "Ajouter au panier", carts_path(plant_id: plant.id), method: :post, class: "btn btn-success w-100" %>
          <% else %>
            <p class="text-muted mt-2">Connectez-vous pour acheter</p>
          <% end %>
        </div>
      </div>
    </div>
  <% end %>
</div>

# plants/edit.html.erb
<!-- app/views/admin/plants/edit.html.erb -->
<div class="container mt-4">
  <h1 class="mb-4">Modifier une plante 🛠️</h1>

  <%= form_with model: @plant, url: admin_plant_path(@plant), method: :patch, local: true do |f| %>
    <div class="mb-3">
      <%= f.label :name, "Nom de la plante", class: "form-label" %>
      <%= f.text_field :name, class: "form-control" %>
    </div>

    <div class="mb-3">
      <%= f.label :price, "Prix (€)", class: "form-label" %>
      <%= f.number_field :price, class: "form-control" %>
    </div>

    <div class="mb-3">
      <%= f.label :description, "Description", class: "form-label" %>
      <%= f.text_area :description, rows: 5, class: "form-control" %>
    </div>

    <div class="mb-3">
      <%= f.label :stock, "Stock", class: "form-label" %>
      <%= f.number_field :stock, class: "form-control" %>
    </div>

    <%= f.submit "Mettre à jour", class: "btn btn-primary w-100" %>
  <% end %>
</div>

# plants/show.html.erb
<div class="card shadow-lg">
  <div class="card-body">
    <h1 class="card-title"><%= @plant.name %></h1>
    <p><strong>Prix :</strong> <%= @plant.price %> €</p>
    <p><strong>Description :</strong> <%= @plant.description %></p>
    <p><strong>Stock :</strong> <%= @plant.stock %> unités</p>

    <% if user_signed_in? %>
      <%= button_to "Ajouter au panier", carts_path(plant_id: @plant.id), method: :post, class: "btn btn-success mb-2" %>
    <% end %>

    <% if user_signed_in? && current_user.admin? %>
      <%= link_to "Modifier cette plante", edit_admin_plant_path(@plant), class: "btn btn-warning me-2" %>
      <%= link_to "Supprimer", admin_plant_path(@plant), method: :delete, data: { confirm: "Supprimer ?" }, class: "btn btn-danger" %>
    <% end %>

    <div class="mt-3">
      <%= link_to "Retour à la liste", plants_path, class: "btn btn-secondary" %>
    </div>
  </div>
</div>

# carts/index.html.erb
<h1 class="text-center mb-4">🛒 Mon Panier</h1>

<% if @cart_items.any? %>
  <table class="table">
    <thead class="table-dark">
      <tr>
        <th>Plante</th>
        <th>Quantité</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody>
      <% @cart_items.each do |item| %>
        <tr>
          <td><%= item.plant.name %></td>
          <td><%= item.quantity %></td>
          <td>
            <%= button_to "Retirer", cart_path(item),
                          method: :delete,
                          class: "btn btn-danger" %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
  <%= link_to "Passer la commande", new_order_path, class: "btn btn-primary" %>
<% else %>
  <p class="alert alert-info">Votre panier est vide.</p>
<% end %>

# carts/destroy.html.erb
<!-- app/views/carts/destroy.html.erb -->
<p>Retrait du panier en cours...</p>

# carts/create.html.erb
<!-- app/views/carts/create.html.erb -->
<p>Ajout au panier en cours...</p>
<!-- Souvent, on fait un redirect dans le controller. -->

# carts/_cart_item.html.erb
<tr>
  <td><%= item.plant.name %></td>
  <td><%= item.quantity %></td>
  <td>
    <%= button_to "Retirer", cart_path(item), method: :delete, class: "btn btn-danger" %>
  </td>
</tr>

# orders/index.html.erb
<h1 class="text-center mb-4">📜 Mes Commandes</h1>

<% if @orders.any? %>
  <% @orders.each do |order| %>
    <div class="card mb-3 shadow-sm">
      <div class="card-body">
        <h5 class="card-title">Commande n°<%= order.id %></h5>
        <p><strong>Total :</strong> <%= order.total_price %> €</p>
        <p><strong>Statut :</strong> <%= order.status %></p>
        <p class="text-muted"><small>Passée le <%= order.created_at.strftime("%d/%m/%Y %H:%M") %></small></p>
      </div>
    </div>
  <% end %>
<% else %>
  <p class="alert alert-info">Aucune commande pour le moment.</p>
<% end %>

# orders/new.html.erb
<h1 class="text-center mb-4">Valider ma commande</h1>

<% if @cart_items.any? %>
  <table class="table shadow">
    <thead class="table-dark">
      <tr>
        <th>Plante</th>
        <th>Quantité</th>
        <th>Total</th>
      </tr>
    </thead>
    <tbody>
      <% total = 0 %>
      <% @cart_items.each do |item| %>
        <tr>
          <td><%= item.plant.name %></td>
          <td><%= item.quantity %></td>
          <td><%= item.plant.price * item.quantity %> €</td>
        </tr>
        <% total += item.plant.price * item.quantity %>
      <% end %>
    </tbody>
  </table>
  <p class="text-end fw-bold">Total : <%= total %> €</p>
  <%= button_to "Confirmer la commande", orders_path, method: :post, class: "btn btn-success w-100" %>
<% else %>
  <p class="alert alert-info">Votre panier est vide.</p>
<% end %>

# orders/create.html.erb
<!-- app/views/orders/create.html.erb -->
<p>Création de la commande en cours...</p>
<!-- Habituellement, on redirige dans le controller, donc peu utile. -->

# orders/_order_card.html.erb
<div class="card mb-3 shadow-sm">
  <div class="card-body">
    <h5 class="card-title">Commande n°<%= order.id %></h5>
    <p class="card-text"><strong>Total :</strong> <%= order.total_price %> €</p>
  </div>
</div>

# layouts/_flash_messages.html.erb
<% if notice %>
  <div class="alert alert-success"><%= notice %></div>
<% end %>
<% if alert %>
  <div class="alert alert-danger"><%= alert %></div>
<% end %>

# layouts/_messages.html.erb
<% if notice %>
  <div class="alert alert-success"><%= notice %></div>
<% end %>

<% if alert %>
  <div class="alert alert-danger"><%= alert %></div>
<% end %>

# layouts/_navbar.html.erb
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand" href="<%= root_path %>">🌿 Plantes</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <%= link_to "Plantes", plants_path, class: "nav-link" %>
        </li>
        <% if user_signed_in? %>
          <li class="nav-item">
            <%= link_to "Mon Panier", carts_path, class: "nav-link" %>
          </li>
          <li class="nav-item">
            <%= link_to "Mes Commandes", orders_path, class: "nav-link" %>
          </li>
          <li class="nav-item">
            <%= link_to "Mon Profil", user_path(current_user), class: "nav-link" %>
          </li>
          <% if current_user.respond_to?(:admin?) && current_user.admin? %>
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                Admin
              </a>
              <ul class="dropdown-menu">
                <li><%= link_to "Gestion des Plantes", admin_plants_path, class: "dropdown-item" %></li>
                <li><%= link_to "Gestion des Utilisateurs", admin_users_path, class: "dropdown-item" %></li>
              </ul>
            </li>
          <% end %>
          <li class="nav-item">
            <%= link_to "Déconnexion", logout_path, method: :delete, class: "nav-link" %>
          </li>
        <% else %>
          <li class="nav-item">
            <%= link_to "S'inscrire", signup_path, class: "nav-link" %>
          </li>
          <li class="nav-item">
            <%= link_to "Se Connecter", login_path, class: "nav-link" %>
          </li>
        <% end %>
      </ul>
    </div>
  </div>
</nav>

# layouts/mailer.html.erb
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <style>
      /* Email styles need to be inline */
    </style>
  </head>

  <body>
    <%= yield %>
  </body>
</html>

# layouts/mailer.text.erb
<%= yield %>

# layouts/application.html.erb
<!DOCTYPE html>
<html lang="fr">
<head>
  <title>Magasin de Plantes</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <!-- Bootstrap -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body>
  <%= render "layouts/navbar" %>
  <div class="container mt-4">
    <%= render "layouts/flash_messages" %>
    <%= yield %>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

# views.rb

# users/new.html.erb
<h1>S'inscrire</h1>
<%= form_with model: @user, url: "/users", local: true do |f| %>
  <div class="mb-3">
    <%= f.label :email, "Email", class: "form-label" %>
    <%= f.email_field :email, class: "form-control" %>
  </div>
  <div class="mb-3">
    <%= f.label :password, "Mot de passe", class: "form-label" %>
    <%= f.password_field :password, class: "form-control" %>
  </div>
  <div class="mb-3">
    <%= f.label :password_confirmation, "Confirmation", class: "form-label" %>
    <%= f.password_field :password_confirmation, class: "form-control" %>
  </div>
  <%= f.submit "S'inscrire", class: "btn btn-primary" %>
<% end %>

# users/edit.html.erb
<h1>Modifier mon profil</h1>

<%= form_with model: @user, local: true do |f| %>
  <% if @user.errors.any? %>
    <div class="alert alert-danger">
      <ul>
      <% @user.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="mb-3">
    <%= f.label :email, "Email", class: "form-label" %>
    <%= f.email_field :email, class: "form-control" %>
  </div>

  <div class="mb-3">
    <%= f.label :name, "Nom", class: "form-label" %>
    <%= f.text_field :name, class: "form-control" %>
  </div>

  <%= f.submit "Enregistrer", class: "btn btn-primary" %>
<% end %>

# users/show.html.erb
<h1>Mon Profil</h1>
<p><strong>Email :</strong> <%= @user.email %></p>
<% if @user.name.present? %>
  <p><strong>Nom :</strong> <%= @user.name %></p>
<% end %>

<%= link_to "Modifier mon profil", edit_user_path(@user), class: "btn btn-primary" %>

