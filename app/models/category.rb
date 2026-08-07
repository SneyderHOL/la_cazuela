# == Schema Information
#
# Table name: categories
# Database name: primary
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(FALSE), not null
#  ancestry   :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_categories_on_ancestry  (ancestry)
#  index_categories_on_name      (name) UNIQUE
#
class Category < ApplicationRecord
  include ActiveScopeable

  has_ancestry
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: true
end
