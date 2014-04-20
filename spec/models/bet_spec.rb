require 'spec_helper'

describe Bet do
  fixtures :bets, :teams

  subject { bets(:sao_w_x_par) }

  ## associations
  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:game) }

  ## validations
  it { expect(subject).to validate_presence_of(:user) }
  it { expect(subject).to validate_presence_of(:game) }
  it { expect(subject).to validate_numericality_of(:team_home_goals).is_greater_than_or_equal_to(0).allow_nil }
  it { expect(subject).to validate_numericality_of(:team_away_goals).is_greater_than_or_equal_to(0).allow_nil }

  ## methods
  it { expect(subject.to_s).to eq("#{subject.game.team_home.short_name} vs #{subject.game.team_away.short_name}") }

  context '#goals?' do
    it 'with goals' do
      expect(subject.goals?).to eq true
    end

    it 'without goals' do
      subject.team_home_goals = nil

      expect(subject.goals?).to eq false
    end
  end
end
