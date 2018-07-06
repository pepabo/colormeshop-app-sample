class User < ApplicationRecord
  validates :account_id, presence: true
  validates :access_token, presence: true
end
