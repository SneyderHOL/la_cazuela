class Avo::Resources::InventoryTransaction < Avo::BaseResource
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
    field :by_admin, as: :boolean
    field :cost, as: :number
    field :error_message, as: :text
    field :ingredient_id, as: :number
    field :kind, as: :select, enum: ::InventoryTransaction.kinds
    field :quantity, as: :number
    field :status, as: :text
    field :ingredient, as: :belongs_to
  end
end
