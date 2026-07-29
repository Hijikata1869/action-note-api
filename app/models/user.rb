class User < ApplicationRecord
  has_secure_password

  has_many :books, dependent: :destroy
  has_many :reading_notes, through: :books

  validates :nickname, presence: true, length: { maximum: 30 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  def safe_attributes
    { id: id, nickname: nickname, email: email }
  end
end
