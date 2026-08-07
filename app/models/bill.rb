# == Schema Information
#
# Table name: bills
# Database name: primary
#
#  id            :bigint           not null, primary key
#  detail        :jsonb
#  total         :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sell_order_id :bigint           not null
#
# Indexes
#
#  index_bills_on_sell_order_id  (sell_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (sell_order_id => sell_orders.id)
#
class Bill < ApplicationRecord
  belongs_to :sell_order

  validates :total, numericality: { greater_than: 0 }
  validate :detail_not_empty

  private

  def detail_not_empty
    parsed_detail = detail.is_a?(Hash) ? detail : detail.to_h

    if parsed_detail.blank?
      errors.add(:detail, "cannot be empty")
    end
  end
end
