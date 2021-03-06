require 'nokogiri'
require 'net/http'

namespace :api do
  namespace :championship do
    desc "Update games"
    task :update, [:jump_n_days, :day] => [:environment] do |t, args|
      day = args[:day].present? ? Time.zone.parse(args[:day]) : Time.zone.now
      day = day + args.fetch(:jump_n_days, 0).to_i.day

      puts "[START #{Time.now.in_time_zone}] api:championship:update => date: #{day}"
      championships = Championship.running(on: day).where.not(url: nil)
      championships.each do |championship|
        print "championship: #{championship}: "
        url = championship.url + "#{championship.url.include?("?") ? "&" : "?"}dates=#{day.strftime("%Y%m%d")}"
        doc = Net::HTTP.get(URI.parse(url))
        json = JSON.parse(doc)

        json_games = json['events']
        json_games.each do |json_game|
          json_teams = json_game['competitions'].first['competitors']

          json_competitor_home = json_teams.select { |team| team['homeAway'] == 'home' }.first
          json_competitor_away = json_teams.select { |team| team['homeAway'] == 'away' }.first

          json_team_home = json_competitor_home['team']
          json_team_away = json_competitor_away['team']

          if !json_team_home['isActive'] && !json_team_away['isActive']
            print 'i'
            next
          end

          team_home = first_or_create_team(json_team_home)
          team_away = first_or_create_team(json_team_away)

          game_external_id = json_game['uid']
          game_played_at = Time.zone.parse(json_game['date'])
          game = Game.where(external_id: game_external_id).first_or_initialize(team_home: team_home, team_away: team_away, championship: championship, played_at: game_played_at)

          if json_game['status']['type']['completed']
            game.team_home_goals = json_competitor_home['score'].to_i
            game.team_away_goals = json_competitor_away['score'].to_i
          end

          print '.'
          game.save

          ClassifyGameWorker.perform_async game.id
        end
        puts

        puts "[FINISH #{Time.now.in_time_zone}] api:championship:update => date: #{day}"
      end
    end

    def first_or_create_team(json)
      external_id = json['uid']
      team_name   = json['name']
      short_name  = json['abbreviation'][0..2].upcase
      image       = URI.parse(json['logo']).open

      Team.where(external_id: external_id).first_or_create(external_id: external_id, name: team_name, short_name: short_name, image: image)
    end
  end
end
