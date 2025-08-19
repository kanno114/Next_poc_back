class Profile
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :latitude, :decimal
  attribute :longitude, :decimal

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  def self.from_params(params)
    new(
      name: params[:name],
      latitude: params[:latitude],
      longitude: params[:longitude]
    )
  end

  def to_user_attributes
    {
      name: name,
    }
  end

  def to_location_attributes
    {
      latitude: latitude,
      longitude: longitude
    }
  end
end