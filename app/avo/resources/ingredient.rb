class Avo::Resources::Ingredient < Avo::BaseResource
  # self.icon = "tabler/outline/users"
  # self.avatar = {
  #   source: :avatar
  # }
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    # field :avatar, as: :avatar
    field :cost, as: :number
    field :high_threshold, as: :number
    field :ingredient_type, as: :select, enum: ::Ingredient.ingredient_types
    field :low_threshold, as: :number
    field :name, as: :text
    field :status, as: :text
    field :stored_quantity, as: :number
    field :unit, as: :select, enum: ::Ingredient.units
    field :recipe, as: :has_one
    field :ingredient_recipes, as: :has_many
    field :recipes, as: :has_many, through: :ingredient_recipes
  end
end
