# == Schema Information
#
# Table name: inventory_transactions
# Database name: primary
#
#  id               :bigint           not null, primary key
#  by_admin         :boolean          default(FALSE), not null
#  cost             :integer          default(0), not null
#  direction        :string           not null
#  error_message    :string
#  quantity         :integer          not null
#  status           :string           not null
#  transaction_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ingredient_id    :bigint           not null
#  order_product_id :bigint
#
# Indexes
#
#  index_inventory_transactions_on_ingredient_id     (ingredient_id)
#  index_inventory_transactions_on_order_product_id  (order_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (order_product_id => order_products.id)
#
class InventoryTransaction < ApplicationRecord
  #                      INVENTORY
  #                          │
  #           ┌──────────────┼──────────────┐
  #           │              │              │
  #        Purchase       Production     Consumption
  #           │              │              │
  #           ▼              ▼              ▼
  #      + inventory     + base stock    - inventory
  #      + value         + value         - value
  #                                         │
  #                                         ▼
  #                                   OrderProduct
  ###########################
  # Supplier purchase
  #       │
  #       ▼
  # Ingredient.cost
  #       │
  #       ▼
  # Ingredient.unit_cost
  #       │
  #       ▼
  # IngredientRecipe.cost
  #       │
  #       ▼
  # Recipe.cost
  #       │
  #       ▼
  # Current Product cost
  ###########################
  # For Base Ingredient
  # Recipe ingredients
  #       │
  #       ▼
  # Production cost
  #       │
  #       ▼
  # Base Ingredient.cost
  #       │
  #       ▼
  # Base Ingredient.unit_cost
  #       │
  #       ▼
  # Product Recipe.cost
  ###########################
  # For Product preparation
  #   OrderProduct
  #       │
  #       ▼
  # Inventory::ConsumeOrderProduct
  #       │
  #       ├── calculate required quantity
  #       ├── lock ingredient
  #       ├── calculate current unit cost
  #       ├── calculate consumption cost
  #       ├── subtract quantity
  #       ├── subtract inventory value
  #       └── create InventoryTransaction
  #              │
  #              ├── transaction_type: consumption
  #              ├── direction: subtraction
  #              ├── ingredient_id
  #              ├── order_product_id
  #              ├── quantity
  #              ├── cost
  #              └── completed
  include AASM

  aasm column: "status" do
    state :pending, initial: true
    state :completed

    event :complete do
      transitions from: :pending, to: :completed
    end
  end

  class InvalidTransactionStatusError < StandardError; end
  class InsufficientStockError < StandardError; end
  class InvalidTransactionError < StandardError; end

  ADDITION_TRANSACTION_TYPES = %w[purchase production].freeze
  SUBTRACTION_TRANSACTION_TYPES = %w[consumption].freeze
  BIDIRECTIONAL_TRANSACTION_TYPES = %w[adjustment].freeze
  COP_CURRENCY_FACTOR = 100.0

  belongs_to :ingredient
  # purchase -> order_product = nil
  # production -> order_product = nil
  # adjustment -> order_product = nil
  # consumption -> order_product = required
  belongs_to :order_product, optional: true

  # purchase -> addition
  # production -> addition
  # consumption -> subtraction
  # adjustment -> addition & subtraction
  enum :transaction_type, {
    consumption: "consumption",
    production: "production",
    adjustment: "adjustment",
    purchase: "purchase"
  }, default: :consumption
  enum :direction, { addition: "addition", subtraction: "subtraction" }

  validates :direction, :status, :transaction_type, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :cost, numericality: { greater_than_or_equal_to: 0 }
  validate :valid_direction_for_transaction_type

  # Transactions are the inventory history/audit trail.
  # Recipes are the cost calculation definition.
  # Ingredients are the current inventory valuation.

  # InventoryTransaction#apply!
  #       │
  #       ├── purchase
  #       │      └── add purchased inventory
  #       │
  #       ├── adjustment
  #       │      └── add/subtract inventory
  #       │
  #       ├── consumption (when an order_product is made) executed in event transition
  #       │      ├── subtract inventory
  #       │      └── create inventory transaction record as completed
  #       │
  #       └── production
  #              │
  #              └── Inventory::ProduceBaseIngredient
  #                      │
  #                      ├── consume recipe ingredients
  #                      ├── calculate production cost
  #                      ├── add inventory to base ingredient
  #                      └── subtract inventory for recipe ingredients
  def apply!
    validate_transaction!

    ActiveRecord::Base.transaction do
      if production?
        apply_production!
      else
        apply_standard_transaction!
      end

      complete!
    end

    true
  rescue ActiveRecord::RecordInvalid,
         Inventory::ProduceBaseIngredient::InsufficientStockError => e
    handle_failure!(e)
  end

  private

  def valid_direction_for_transaction_type
    case transaction_type
    when *ADDITION_TRANSACTION_TYPES
      errors.add(:direction, "must be addition") unless addition?
    when *SUBTRACTION_TRANSACTION_TYPES
      errors.add(:direction, "must be subtraction") unless subtraction?
    end
  end

  def validate_transaction!
    if completed?
      raise InvalidTransactionStatusError, "the transaction was already completed"
    end
    unless ingredient
      raise InvalidTransactionError, "ingredient is required"
    end
    if consumption? && order_product.nil?
      raise InvalidTransactionError, "order product is required for consumption transactions"
    end
    if !consumption? && order_product.present?
      raise InvalidTransactionError, "order product can only be associated with consumption transactions"
    end
  end

  def apply_production!
    unless ingredient.base?
      raise InvalidTransactionError, "production transactions require a base ingredient"
    end

    producer = Inventory::ProduceBaseIngredient.new(ingredient, quantity)
    producer.call
    self.cost = producer.production_cost
    ingredient.update!(stored_quantity: ingredient.stored_quantity + quantity,
                       cost: ingredient.cost + cost)

    save!
  end

  def lock_ingredient!
    @locked_ingredient = Ingredient.lock.find(ingredient.id)
  end

  def apply_standard_transaction!
    lock_ingredient!
    self.cost = calculated_transaction_cost
    @locked_ingredient.update!(stored_quantity: calculated_stored_quantity,
                               cost: calculated_inventory_cost)

    save!
  end

  def calculated_stored_quantity
    quantity_change = addition? ? quantity : -quantity
    new_quantity = @locked_ingredient.stored_quantity + quantity_change

    raise InsufficientStockError, "#{ingredient.name} has insufficient stock" if new_quantity.negative?

    new_quantity
  end

  # purchase cost = amount actually paid for the purchased inventory
  # production cost = cost of ingredients consumed to produce it
  # consumption cost = current unit cost × quantity consumed
  # adjustment cost = value assigned to the adjustment
  def calculated_inventory_cost
    if addition?
      @locked_ingredient.cost + cost
    else
      @locked_ingredient.cost - cost
    end
  end

  # InventoryTransaction.cost is the monetary value associated with the quantity change
  # represented by this transaction
  def calculated_transaction_cost
    # it should determine the new total inventory value
    return cost if addition?

    # value of the quantity being removed
    (@locked_ingredient.unit_cost * quantity).round
  end

  def handle_failure!(exception)
    error_msg = "Insufficient stock. Error: #{exception.message}"
    update(error_message: error_msg)

    raise InsufficientStockError, error_msg
  end
end
