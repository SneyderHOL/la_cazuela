# == Schema Information
#
# Table name: allocations
# Database name: primary
#
#  id         :bigint           not null, primary key
#  active     :boolean          not null
#  kind       :integer          not null
#  name       :string           not null
#  status     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_allocations_on_name  (name) UNIQUE
#
class Allocation < ApplicationRecord
  include AllocationAasm
  include ActiveScopeable

  has_many :sell_orders, dependent: :restrict_with_error

  enum :kind, { desk: 0, delivery: 1, takeout: 2 }

  validates :name, :kind, :status, presence: true
  validates :name, uniqueness: true
  validates :active, exclusion: [ nil ]

  # scope :current_pending_delivery, -> {
  #   where(kind: :delivery, active: true)
  #     .joins(:sell_orders)
  #     .where(sell_orders: { created_at: Time.zone.today.beginning_of_day..Time.current,
  #            status: [:opened, :packed, :invoicing]})
  # }
end
