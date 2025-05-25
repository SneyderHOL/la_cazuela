class User < ApplicationRecord
  include ActiveScopeable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { waiter: "waiter", admin: "admin", kitchen_auxiliar: "kitchen_auxiliar" }, default: :kitchen_auxiliar

  validates :name, :role, presence: true
  validates :active, exclusion: [ nil ]
end
