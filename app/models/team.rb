class Team < ApplicationRecord
  ## attributes
  has_attached_file :image

  ## validations
  validates :name,       presence: true, uniqueness: true, length: { maximum: 50, minimum: 3 }
  validates :short_name, presence: true, length: { maximum:  3, minimum: 3 }

  validates :image, attachment_presence: true,
                    attachment_content_type: { content_type: %w{ image/png image/gif image/jpg } }

  ## scopes
  default_scope { order(:name) }

  ## methods
  def to_s
    name
  end
end
