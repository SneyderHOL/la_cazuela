class Avo::Resources::OrderProduct < Avo::BaseResource
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
    field :inventory_consumed_at, as: :datetime
    field :note, as: :text
    field :order_id, as: :number
    field :product_id, as: :number
    field :quantity, as: :number
    field :recipe_id, as: :number
    field :status, as: :text
    field :order, as: :belongs_to
    field :product, as: :belongs_to
    field :recipe, as: :belongs_to
  end
end
