class Code

	attr_accessor :colors

	@@color_options = %w(red green blue yellow orange purple)

	def initialize (colors = nil)
		 @colors = colors ? colors.split(" ") : randomize_colors
	end

	def self.color_options
		@@color_options
	end

	def validate(choice)
		valid = true

		choice.each do |color|
			valid = false unless @@color_options.include? color
		end

		valid = false unless choice.length == 4

		return valid
	end


	private

	def randomize_colors
		@colors = []
		4.times do			
			@colors << random_color
		end
		@colors
	end

	def random_color
		random = Random.new
		@@color_options[random.rand(6)]
	end

end


class Game

	def initialize
		@correct_code = Code.new
		start_game
	end

	private

	def start_game
		@turn = 1
		turn
	end

	def next_turn
		@turn += 1
		turn
	end

	def turn
		puts "Guess the code! Enter 'help' for instructions."
		choice = gets.chomp

		if choice.downcase == "help"
			help
			choice = gets.chomp
		end

		@guess = Code.new(choice)
		validate ? check_guess : invalid_guess
		next_turn
	end

	def help
		puts "\nIn Mastermind, the computer has created a code"
		puts "of four colors! You have 12 turns to guess the"
		puts "correct code! After each guess, the computer"
		puts "will tell you how many colors you had in the"
		puts "correct place, and how many colors were correct"
		puts "but in the wrong place!\n"
		puts "Enter four colors, separated by spaces."
		puts "The color options are"
		puts Code.color_options.join(", ")
		puts ""
		puts "Now try and guess the code!"
	end

	def validate
		@correct_code.validate(@guess.colors)
	end

	def check_guess
		@guess.colors == @correct_code.colors ? correct_guess : provide_feedback
	end

	def invalid_guess
		puts "Invalid guess, try again"
		turn
	end

	def correct_guess
		puts "You did it, champ! Type 'yes' for New Game!"
		new_game
	end

	def provide_feedback
		perfect_array = find_perfect
		perfect = perfect_array[0]
		detected = perfect_array[1]

		correct = find_correct(detected)
		puts "\nYou matched #{perfect} colors with their correct location!"
		puts "You matched #{correct} colors without the proper location!"
		puts "You have #{12-@turn} turns left!"
		puts ""

		if @turn == 12
			puts "You're out of turns! Sorry bro."
			puts "The correct code was #{@correct_code.colors.join(" ")}"
			puts "\nType 'yes' to start a new game."
			new_game
		end
	end

	def find_perfect
		perfect = 0
		detected = []
			@correct_code.colors.each_with_index do |correct, i|
			@guess.colors.each_with_index do |guess, i2|
				if guess == correct && i == i2
					perfect += 1
					detected << i2
				end
			end
		end
		[perfect, detected]
	end

	def find_correct (detected)
		imperfect = 0
		removed = []
		@correct_code.colors.each_with_index do |correct, i|
			unless detected.include? i
				found = false
				@guess.colors.each_with_index do |guess, i2|
						unless detected.include? i2
							if guess == correct && found == false
								imperfect += 1 unless removed.include? i2
								removed << i2
								found = true
							end
						end
				end
			end
		end
		return imperfect
	end

	def new_game
		new_game = gets.chomp.downcase
		exit unless new_game == 'yes'
		game = Game.new
	end
end

game = Game.new
