class Book < ApplicationRecord
  belongs_to :user

  enum :status, { finished: 0, reading: 1, tsundoku: 2 }, default: :finished, validate: true

  validates :title, :author, presence: true
end
