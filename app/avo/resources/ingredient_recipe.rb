class Avo::Resources::IngredientRecipe < Avo::BaseResource
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
    field :recipe_id, as: :number
    field :required_quantity, as: :number
    field :ingredient, as: :belongs_to
    field :recipe, as: :belongs_to
  end
end
