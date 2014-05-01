class BetSerializer < ActiveModel::Serializer
  ## bet attributes
  attributes :id, :team_home_goals, :team_away_goals

  ## game attributes
  attributes :team_home, :team_away, :round, :team_home_image_url, :team_away_image_url, :weekday, :time, :date

  ## methods
  def round
    object.round.to_s
  end

  def weekday
    I18n.t("date.abbr_day_names")[object.played_at.strftime("%w").to_i]
  end

  def time
    object.played_at.strftime("%H:%M")
  end

  def date
    object.played_at.strftime("%d/%m")
  end

  def team_home
    object.team_home.to_s
  end

  def team_home_image_url
    object.team_home.image.url
  end

  def team_away
    object.team_away.to_s
  end

  def team_away_image_url
    object.team_away.image.url
  end
end