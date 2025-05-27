class Book < ApplicationRecord
  has_many :pages, dependent: :destroy

  include PgSearch::Model

  pg_search_scope :search_by_title_and_description,
    against: [ :title, :description ],
    using: {
    tsearch: { prefix: true }
  }
end
