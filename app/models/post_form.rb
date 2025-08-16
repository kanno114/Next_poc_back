class PostForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :body, :string
  attribute :event_datetime, :string
  attribute :user_id, :integer
  attribute :location_id, :integer
  attribute :latitude, :float
  attribute :longitude, :float
  attribute :tag_ids, array: true, default: []

  validates :title, presence: true, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 1000 }
  validates :event_datetime, presence: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  def self.from_params(params)
    new(
      title: params[:title],
      body: params[:body],
      event_datetime: params[:event_datetime],
      user_id: params[:user_id],
      location_id: params[:location_id],
      latitude: params.dig(:location, :latitude),
      longitude: params.dig(:location, :longitude),
      tag_ids: params[:tag_ids] || []
    )
  end

  def to_post_attributes
    attributes = {
      title: title,
      body: body,
      event_datetime: parse_datetime_safely(event_datetime)
    }

    # user_idが送信されている場合のみ含める
    attributes[:user_id] = user_id if user_id.present?

    # location_idが送信されている場合のみ含める
    attributes[:location_id] = location_id if location_id.present?

    # tag_idsが空でない場合のみ含める
    attributes[:tag_ids] = tag_ids if tag_ids.present?

    attributes
  end

  def to_location_attributes
    {
      latitude: latitude,
      longitude: longitude
    }
  end

  private

  def parse_datetime_safely(datetime_string)
    return nil if datetime_string.blank?

    begin
      # ISO形式の文字列をDateTimeオブジェクトに変換
      DateTime.parse(datetime_string)
    rescue ArgumentError => e
      Rails.logger.error "Failed to parse event_datetime: #{datetime_string}, Error: #{e.message}"
      nil
    end
  end
end