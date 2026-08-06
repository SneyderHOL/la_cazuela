class Avo::Resources::Recipe < Avo::BaseResource
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
    field :ingredient_id, as: :number
    field :name, as: :text
    field :product_id, as: :number
    field :status, as: :text
    field :product, as: :belongs_to
    field :ingredient, as: :belongs_to
    field :ingredient_recipes, as: :has_many
    field :ingredients, as: :has_many, through: :ingredient_recipes
    field :order_products, as: :has_many
  end
end
