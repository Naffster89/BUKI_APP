class Book < ApplicationRecord
  has_many :pages, dependent: :destroy
  has_one_attached :cover_image
end
