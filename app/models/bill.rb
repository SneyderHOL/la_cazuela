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
