class Recording < ApplicationRecord
  belongs_to :user
  belongs_to :page
  has_one_attached :audio
end
