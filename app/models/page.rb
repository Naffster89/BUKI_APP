class Page < ApplicationRecord
  belongs_to :book

  has_one_attached :photo
end
