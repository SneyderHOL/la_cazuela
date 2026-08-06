class Avo::Resources::User < Avo::BaseResource
  self.icon = "tabler/outline/users"
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
    field :email, as: :text
    field :name, as: :text
    field :nickname, as: :text
    field :role, as: :select, enum: ::User.roles
  end
end
