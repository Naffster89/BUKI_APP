class Page < ApplicationRecord
  belongs_to :book

  has_one_attached :photo
  has_many :recordings, dependent: :destroy
end
