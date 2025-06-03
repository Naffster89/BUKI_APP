class Book < ApplicationRecord
  belongs_to :user, optional: true

  has_many :pages, dependent: :destroy
  has_one_attached :cover_image

  acts_as_favoritable

  include PgSearch::Model

  pg_search_scope :search_by_title_and_description,
    against: [:title, :description, :author],
    using: {
      tsearch: { prefix: true }
    }
end
