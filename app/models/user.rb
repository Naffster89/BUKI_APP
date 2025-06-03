class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :recordings, dependent: :destroy

  before_validation :set_languages
  after_initialize do
    self.languages ||= []
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  acts_as_favoritor

  def set_languages
    if languages.empty?
      self.languages = ["EN"]
    else
      self.languages = languages.reject(&:blank?)
    end
  end
end
