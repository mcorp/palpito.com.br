class Bet < ActiveRecord::Base
  ## associations
  belongs_to :user
  belongs_to :game

  ## validations
  validates :user, presence: true
  validates :game, presence: true
  validates :team_home_goals, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :team_away_goals, presence: true, numericality: { greater_than_or_equal_to: 0 }

  ## delegates
  delegate :round,     to: :game
  delegate :played_at, to: :game
  delegate :team_home, to: :game
  delegate :team_away, to: :game

  ## methods
  def goals?
    team_home_goals.present? and team_away_goals.present?
  end

  def to_s
    "#{team_home.short_name} vs #{team_away.short_name}"
  end
end
