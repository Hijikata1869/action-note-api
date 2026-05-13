class User < ApplicationRecord
  has_secure_password

  validates :nickname, presence: true, length: { maximum: 30 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
