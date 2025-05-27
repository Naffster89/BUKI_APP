class Book < ApplicationRecord
  has_many :pages, dependent: :destroy
  acts_as_favoritable
end
