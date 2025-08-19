class Post < ApplicationRecord
  belongs_to :user
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, presence: true, length: { maximum: 100 }
  validates :body,  presence: true, length: { maximum: 1000 }
  validates :event_datetime, presence: true
end
