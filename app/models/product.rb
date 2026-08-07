# == Schema Information
#
# Table name: products
# Database name: primary
#
#  id          :bigint           not null, primary key
#  active      :boolean          not null
#  detail      :string
#  name        :string           not null
#  price       :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           not null
#
# Indexes
#
#  index_products_on_category_id  (category_id)
#  index_products_on_name         (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
class Product < ApplicationRecord
  include ActiveScopeable

  belongs_to :category
  has_one :recipe, dependent: :restrict_with_error
  has_many :order_products, dependent: :restrict_with_error
  has_many :orders, through: :order_products

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :active, exclusion: [ nil ]
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :detail, length: { maximum: 300 }, allow_nil: true
end
