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
  include ActiveScopeable
  include AASM

  aasm column: "status" do
    state :available, initial: true
    state :busy, :on_hold, :cleaning

    event :take do
      transitions from: %i[ available on_hold cleaning ], to: :busy
    end

    event :reserve do
      transitions from: %i[ available cleaning ], to: :on_hold
    end

    event :clean do
      transitions from: %i[ available on_hold ], to: :cleaning
      transitions from: :busy, to: :cleaning, guard: :has_no_current_orders?
    end

    event :free do
      transitions from: %i[ available on_hold cleaning ], to: :available
      transitions from: :busy, to: :available, guard: :has_no_current_orders?
    end
  end

  has_many :sell_orders, dependent: :restrict_with_error
  has_many :orders, through: :sell_orders

  enum :kind, { desk: 0, delivery: 1, takeout: 2 }

  validates :name, :kind, :status, presence: true
  validates :name, uniqueness: true
  validates :active, exclusion: [ nil ]

  scope :active_service, ->(kinds, statuses) {
    where(active: true, kind: kinds, status: statuses)
  }

  def current_open_sell_order
    sell_orders.sales_by_date(Time.zone.today).opened.first
  end

  private

  def has_no_current_orders?
    sell_orders.current_open_sales.empty?
  end
end
