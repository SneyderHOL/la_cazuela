class Avo::Resources::Bill < Avo::BaseResource
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
    field :detail, as: :code
    field :sell_order_id, as: :number
    field :total, as: :number
    field :sell_order, as: :belongs_to
  end
end
