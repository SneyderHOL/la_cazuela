class Avo::Resources::Allocation < Avo::BaseResource
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
    field :active, as: :boolean
    field :kind, as: :select, enum: ::Allocation.kinds
    field :name, as: :text
    field :status, as: :text
    field :sell_orders, as: :has_many
  end
end
