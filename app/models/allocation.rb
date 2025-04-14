class Allocation < ApplicationRecord
  include AllocationAasm
  include ActiveScopeable

  has_many :orders

  enum :kind, { desk: 0, delivery: 1 }

  validates :name, :kind, :status, presence: true
  validates :name, uniqueness: true
  validates :active, exclusion: [ nil ]
end
