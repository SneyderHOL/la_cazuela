# == Schema Information
#
# Table name: funds
# Database name: primary
#
#  id               :bigint           not null, primary key
#  amount           :integer          not null
#  detail           :string           not null
#  is_deposit       :boolean          not null
#  transaction_date :date             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_funds_on_transaction_date  (transaction_date)
#
class Fund < ApplicationRecord
  before_create :set_transaction_date

  validates :amount, numericality: { greater_than: 0 }
  validates :detail, presence: true
  validates :transaction_date, presence: true, on: :create
  validates :is_deposit, exclusion: [ nil ]
  validates :transaction_date,
            uniqueness: {
              scope: :is_deposit, conditions: -> { where(is_deposit: true) }
            },
            if: :is_deposit?
  validate :check_if_deposit_of_day_exists, on: :create, unless: :is_deposit?

  private

  def check_if_deposit_of_day_exists
    unless self.class.where(is_deposit: true, transaction_date: Time.zone.now.to_date).exists?
      errors.add(:base, "there is no deposit of the day")
    end
  end

  def set_transaction_date
    return if transaction_date

    self.transaction_date = Time.zone.now.to_date
  end
end
