class Code

	attr_accessor :colors

	@@color_options = %w(red green blue yellow orange purple)

	def initialize (colors = nil)
		 @colors = colors ? colors.split(" ") : randomize_colors
	end

	def self.color_options
		@@color_options
	end

	def valid?
		valid = true

		@colors.each do |color|
			valid = false unless @@color_options.include? color
		end

		valid = false unless @colors.length == 4

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

class Player
	attr_accessor :code

	def invalid_guess
		puts "Invalid guess, try again"
		guess
	end


end
	
class Human < Player

	def guess
		puts "Guess the code! Enter 'help' for instructions."
		choice = gets.chomp
		if choice.downcase == "help"
			Game.guess_help
			choice = gets.chomp
		end
		@code = Code.new(choice)
		invalid_guess unless @code.valid?
	end

	def create_code
		puts "Please enter a code for the computer to guess."
		puts "For help, enter 'help'."
		choice = gets.chomp
		if choice.downcase == "help"
			Game.create_help
			choice = gets.chomp
		end

		@code = Code.new(choice)
		unless @code.valid?
			puts "Invalid code, please enter valid code or 'help'"
			create_code
		end
	end
end

class Ai < Player
	attr_writer :feedback
	def initialize
		@feedback = 0
		@bank = []
		@guessed_array = []
	end
	def guess(turn)
		sleep 2
		case turn
		when 1
			@code = Code.new("red red red red")
		when 2
			@feedback.times {@bank << "red"}
			@code = Code.new("blue blue blue blue")
		when 3
			@feedback.times {@bank << "blue"} if @bank.length < 4
			if @bank.length < 4
				@code = Code.new("green green green green")
			else
				@code = Code.new(random_guess)
			end
		when 4
			@feedback.times {@bank << "green"} if @bank.length < 4
			if @bank.length < 4
				@code = Code.new("purple purple purple purple")
			else
				@code = Code.new(random_guess)
			end
		when 5
			@feedback.times {@bank << "purple"} if @bank.length < 4
			if @bank.length < 4
				@code = Code.new("orange orange orange orange")
			else
				@code = Code.new(random_guess)
			end
		when 6
			@feedback.times {@bank << "orange"} if @bank.length < 4
			if @bank.length < 4
				@code = Code.new("yellow yellow yellow yellow")
			else
				@code = Code.new(random_guess)
			end
		when 7
			@feedback.times {@bank << "yellow"} if @bank.length < 4
			@code = Code.new(random_guess)
		else
			@code = Code.new(random_guess)
		end
		puts @code.colors.join(" ")
	end

	def random_guess
		code = @bank.shuffle.join(" ")
		while @guessed_array.include? code
			code = @bank.shuffle.join(" ")
		end
		@guessed_array << code
		return code
	end

	def create_code
		@code = Code.new
	end
end



class Game

	def initialize
		start_game
	end

	private

	def start_game
		@turn = 1
		define_players
		@creator.create_code
		turn
	end

	def define_players
		puts "Would you like to be player 1 (code creator) or player 2 (guesser)?"
		puts "Enter 1 or 2"
		choice = gets.chomp
		case choice
		when "1"
			@creator = Human.new
			@guesser = Ai.new
		when "2"
			@creator = Ai.new
			@guesser = Human.new
		else
			puts "Please choose 1 or 2"
			define_players
		end

	end


	def next_turn
		@turn += 1
		turn
	end

	def turn
		@guesser.class == Human ? @guesser.guess : @guesser.guess(@turn)
		check_guess
		next_turn
	end

	def self.guess_help
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

	def self.create_help
		puts "\nCreate a code of four colors."
		puts "The computer will have 12 turns to guess the"
		puts "correct code! After each guess, the computer"
		puts "will get feedback on how many colors it had in the"
		puts "correct place, and how many colors were correct"
		puts "but in the wrong place!\n"
		puts "Enter four colors, separated by spaces."
		puts "The color options are"
		puts Code.color_options.join(", ")
		puts ""
		puts "Now create your code!"
	end

	def check_guess
		@guesser.code.colors == @creator.code.colors ? correct_guess : provide_feedback
	end

	def correct_guess
		if @guesser.class == Human
			puts "You did it, champ! Type 'yes' for New Game!"
		else
			puts "The computer guessed your code! Type 'yes' to try again!"
		end
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

		@guesser.feedback = perfect + correct if @guesser.class == Ai

		if @turn == 12
			if @guesser.class == Human
				puts "You're out of turns! Sorry bro."
				puts "The correct code was #{@creator.code.colors.join(" ")}"
			else
				puts "You fooled the computer!"
			end
			puts "\nType 'yes' to start a new game."
			new_game
		end
	end

	def find_perfect
		perfect = 0
		detected = []
			@creator.code.colors.each_with_index do |correct, i|
			@guesser.code.colors.each_with_index do |guess, i2|
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
		@creator.code.colors.each_with_index do |correct, i|
			unless detected.include? i
				found = false
				@guesser.code.colors.each_with_index do |guess, i2|
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
