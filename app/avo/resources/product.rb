class Avo::Resources::Product < Avo::BaseResource
  self.icon = "tabler/outline/package"
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
    field :active, as: :boolean
    field :detail, as: :text
    field :name, as: :text
    field :price, as: :number
    field :category_id, as: :number
    field :category, as: :belongs_to
    field :recipe, as: :has_one
    field :order_products, as: :has_many
    field :orders, as: :has_many, through: :order_products
  end
end
