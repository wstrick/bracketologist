class BracketEngine
  # Applies the log5 formula to determine the odds of one team beating another.
  def self.log5(a, b)
    return a*(1 - b)/(a*(1 - b) + (1 - a)*b)
  end

  # Accepts an array of teams in the order of their seeding (so that the matchups
  # work). Returns an array of the winning teams from the matchup. So for the first
  # round, it takes 16 teams and returns the 8 winners. It figures out the odds of
  # each team winning and determines a winner based on the random number generator.
  def self.reduce(bracket)
    winners = []

    (0 .. ((bracket.length()/2) - 1)).each do |index|
      opponent_a = bracket[index]
      opponent_b = bracket[bracket.length - index - 1]

      puts "Can't find team #{opponent_a}" if (!self.teams.include?(opponent_a))
      puts "Can't find team #{opponent_b}" if (!self.teams.include?(opponent_b))

      winning_pct_for_a = log5(self.teams[opponent_a], self.teams[opponent_b])

      puts opponent_a + " has a " + (winning_pct_for_a * 100).round().to_s + "% chance of beating " + opponent_b

      if rand() > winning_pct_for_a
        puts "Winner: " + opponent_b + "\n\n"
        winners << opponent_b
      else
        puts "Winner: " + opponent_a + "\n\n"
        winners << opponent_a
      end
    end

    return winners
  end

  def self.play_in_game(game, teams)
    puts "Play-in #{game}"
    BracketEngine.reduce(teams)
  end

  def self.teams
    @@teams ||= {}

    return @@teams if !@@teams.empty?

    # Read in the ratings from Ken Pomeroy's Web site. A data entry avoidance technique,
    # highly brittle. The result is a hash with the names of the schools as keys and
    # a percentage chance of winning as the values. Percentages are versus an average
    # team in Pomeroy's system.
    File.open("ratings.tsv").each do |line|
      fields = line.split(/\t/)

      @@teams[fields[0].rstrip] = fields[1].to_f
    end

    return @@teams
  end
end

class Bracket
  attr_accessor :regions, :final_four_teams, :region_order

  def initialize
    # Must be in order of seeding. Names must match the keys in $teams
    #
    # Pick play-in game winners.
    round_1_g1 = BracketEngine.play_in_game("Game 2", ["Iowa", "Tennessee"])
    round_1_g2 = BracketEngine.play_in_game("Game 2", ["North Carolina St.", "Xavier"])
    round_1_g3 = BracketEngine.play_in_game("Game 3", ["Cal Poly", "Texas Southern"])
    round_1_g4 = BracketEngine.play_in_game("Game 4", ["Albany", "Saint Mary's"])

    west = [ "Arizona", "Wisconsin", "Creighton", "San Diego St.", "Oklahoma",
      "Baylor", "Oregon", "Gonzaga", "Oklahoma St.", "BYU",
      "Nebraska", "North Dakota St.", "New Mexico St.", "Louisiana Lafayette",
      "American", "Weber St." ]

    midwest = [ "Wichita St.", "Michigan", "Duke", "Louisville", "Saint Louis",
      "Massachusetts", "Texas", "Kentucky", "Kansas St.", "Arizona St.",
      round_1_g1[0], round_1_g2[0], "Manhattan", "Mercer",
      "Wofford", round_1_g3[0] ]

    east = [ "Virginia", "Villanova", "Iowa St.", "Michigan St.", "Cincinnati",
      "North Carolina", "Connecticut", "Memphis", "George Washington",
      "Saint Joseph's", "Providence", "Harvard", "Delaware", "North Carolina Central",
      "Milwaukee", "Coastal Carolina" ]


    south = [ "Florida", "Kansas", "Syracuse", "UCLA", "VCU",
      "Ohio St.", "New Mexico", "Colorado", "Pittsburgh", "Stanford",
      "Dayton", "Stephen F. Austin", "Tulsa", "Western Michigan",
      "Eastern Kentucky", round_1_g4[0] ]

    # This order is important so that the proper teams meet in the final four.
    @regions = { "Midwest" => midwest, "East" => east, "South" => south, "West" => west }

    # BracketEngine.reduce works from outermost pair in towards the middle
    @region_order = [ "West", "South", "East", "Midwest" ]

    @final_four_teams = []
  end
end

