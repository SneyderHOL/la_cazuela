class Avo::Resources::Category < Avo::BaseResource
  self.icon = "tabler/outline/folder"
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
    field :ancestry, as: :text
    field :name, as: :text
    field :products, as: :has_many
  end
end
