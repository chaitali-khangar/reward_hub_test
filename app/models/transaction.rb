class Transaction < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10_000_000 }
  validates :country, presence: true
  validates :external_id, presence: true, uniqueness: true
end
