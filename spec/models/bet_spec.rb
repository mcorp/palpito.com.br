require 'spec_helper'

describe Bet do
  fixtures :bets, :games, :teams

  subject { bets(:sao_w_x_par) }

  ## associations
  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:game) }

  ## validations
  it { expect(subject).to validate_presence_of(:user) }
  it { expect(subject).to validate_presence_of(:game) }
  it { expect(subject).to validate_presence_of(:team_home_goals).on(:update) }
  it { expect(subject).to validate_presence_of(:team_away_goals).on(:update) }
  it { expect(subject).to validate_numericality_of(:team_home_goals).is_greater_than_or_equal_to(0) }
  it { expect(subject).to validate_numericality_of(:team_away_goals).is_greater_than_or_equal_to(0) }

  context 'Played game dont accept bets' do
    it 'in the future' do
      subject.game.played_at = DateTime.now + 1
      subject.team_home_goals = 4
      expect(subject.valid?).to eq true
    end

    it 'in the past' do
      subject.game.played_at = DateTime.now - 1
      subject.team_home_goals = 4
      expect(subject.valid?).to eq false
      expect(subject.errors[:base].count).to eq 1
    end

    it 'dont change goals' do
      subject.game.played_at = DateTime.now - 1
      subject.points = 3
      expect(subject.valid?).to eq true
    end
  end

  ## delegates
  it { expect(subject.round).to eq subject.game.round }
  it { expect(subject.played_at).to eq subject.game.played_at }
  it { expect(subject.team_home).to eq subject.game.team_home }
  it { expect(subject.team_away).to eq subject.game.team_away }
  it { expect(subject.bettable?).to eq subject.game.bettable? }

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
