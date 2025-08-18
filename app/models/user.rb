class User < ApplicationRecord
  has_secure_password validations: false

  has_many :user_identities, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :daily_logs, dependent: :destroy
  has_one :location, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, length: { maximum: 100 }, allow_nil: true
  validates :image, length: { maximum: 255 }, allow_nil: true
end
