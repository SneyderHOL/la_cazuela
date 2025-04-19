class Bill < ApplicationRecord
  belongs_to :order

  validates :total, numericality: { greater_than_or_equal_to: 0 }

  def detail_hash
    eval(detail)
  end
end
