class Avo::Resources::Order < Avo::BaseResource
  self.icon = "tabler/outline/shopping-cart"
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
    field :sell_order_id, as: :number
    field :status, as: :text
    field :sell_order, as: :belongs_to
    field :order_products, as: :has_many
    field :products, as: :has_many, through: :order_products
  end
end
