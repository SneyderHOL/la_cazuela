class Category < ApplicationRecord
  include ActiveScopeable

  has_ancestry
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: true
end
