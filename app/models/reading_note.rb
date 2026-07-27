class ReadingNote < ApplicationRecord
  belongs_to :book

  validates :content, presence: true, length: { maximum: 10_000 }
  validates :book_id, uniqueness: true
end
