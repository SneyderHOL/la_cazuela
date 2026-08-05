class Avo::Resources::SellOrder < Avo::BaseResource
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
    field :allocation_id, as: :number
    field :cash_change, as: :number
    field :cash_pay, as: :number
    field :payment_type, as: :select, enum: ::SellOrder.payment_types
    field :status, as: :text
    field :total, as: :number
    field :allocation, as: :belongs_to
    field :orders, as: :has_many
    field :bill, as: :has_one
  end
end
