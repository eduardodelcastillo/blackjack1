#oop_blackjack.rb Wed 7 Oct 2015

require 'pry'

class Card
  attr_reader :value, :suit

  def initialize(value, suit)
    @value = value
    @suit = suit
  end

  def to_s
    "--#{translate_value(value)} of #{suit}--".center(42)
  end

  def translate_value(value)
    if (1..10).include?(value.to_i)
      value
    else
      case value
      when "J"
        "Jack"
      when "Q"
        "Queen"
      when "K"
        "King"
      when "A"
        "Ace"
      end
    end
  end
end

class Deck
  attr_accessor :value, :suit, :cards

  def initialize
    @cards = []
    card_suit = %w(Hearts Diamonds Spades Clubs)
    card_value = %w(2 3 4 5 6 7 8 9 10 J Q K A)
    card_suit.each do |suit|
      card_value.each do |value|
        @cards << Card.new(value, suit)
      end
    end
    shuffle_cards
  end

  def shuffle_cards
    cards.shuffle!
  end

  def deal_card
    cards.pop
  end
end

module Hand
  def calculate_total(cards)
    total = 0
    ace_count = 0
    cards.each do |card|
      if (1..10).include?(card.value.to_i)
        total += card.value.to_i
      elsif %w(J Q K).include?(card.value)
        total += 10
      elsif card.value == 'A'
        total += 11
        ace_count += 1
      end
    end
    #correct for Aces
    ace_count.times do 
      total -= 10 if total > 21
    end
    total
  end

  def is_blackjack?(cards)
    calculate_total(cards) == 21
  end

  def is_busted?(cards)
    calculate_total(cards) > 21
  end
end

class Player
  include Hand
  attr_accessor :cards, :total, :score
  attr_reader :name

  def initialize(name)
    @name = name 
    @cards = []
    @total = 0
    @score = 0
  end

  def show_cards
    system "clear"
    puts "#{name} has the following cards: "
    puts cards
    puts "#{name} has a total of #{calculate_total(cards)}" 
  end 

  def show_first_card
    puts "#{name} has the first card: " 
    puts "#{cards[0]}"
  end

  def clear_hand
    self.cards = []
  end
end

class Game
  include Hand
  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new  
    set_number_of_decks      
    begin
      puts "--÷--÷--÷--÷--÷--÷--÷--÷--÷--÷--".center(42)
      puts "Welcome to BLACKJACK!".center(42)
      puts "--÷--÷--÷--÷--÷--÷--÷--÷--÷--÷--".center(42)
      puts "What is your name?"     
      @player = Player.new(gets.chomp)
      @dealer = Player.new("Dealer " + dealer_for_today)      
      puts "Welcome #{player.name}. Your dealer for today is #{dealer.name}."
      puts "Let's play!"
      puts "Press enter to continue..."
    end until gets.chomp
      deal_initial_cards  
  end

  def set_number_of_decks
    deck.cards = deck.cards * [1, 2, 3, 4, 5, 6, 7, 8].sample
  end

  def deal_initial_cards
    player.clear_hand
    dealer.clear_hand
    2.times do 
      player.cards << deck.deal_card
      dealer.cards << deck.deal_card
    end
  end

  def play
    player.show_cards
    player.total = calculate_total(player.cards)
    if is_blackjack?(player.cards)
      puts "#{player.name} has blackjack! #{player.name} wins!"
      player.score += 1
    else
      dealer.show_first_card
      hit_or_stay
    end
    show_score
    play_again
  end

  def play_again
    puts "Does #{player.name} want to play again? (y, n)"
    play_again = gets.chomp.downcase
    if play_again == 'y'
      deal_initial_cards
      play
    end
  end

  def hit_or_stay
    loop do
      puts "Does #{player.name} want to hit or stay? (h for hit, s for stay)" 
      hit_or_stay = gets.chomp.downcase
      if hit_or_stay == 'h'
        player.cards << deck.deal_card
        player.show_cards
        player.total = calculate_total(player.cards)
        if is_busted?(player.cards)
          puts "#{player.name} busted at #{player.total}. #{player.name} loses!"
          dealer.score += 1
          break
        elsif player.total == 21
          dealer_turn
          break
        end
      elsif hit_or_stay == 's' 
        dealer_turn
        break      
      else
        puts 'Please type h to hit or s to stay.'
      end
    end
  end

  def dealer_turn
    dealer.show_cards
    dealer.total = calculate_total(dealer.cards)
    if is_blackjack?(dealer.cards)
      puts "#{dealer.name} has blackjack! #{player.name} loses!"
      dealer.score += 1
    else
      while dealer.total < 17
        puts "Dealing another card for dealer..."
        dealer.cards << deck.deal_card
        dealer.show_cards
        dealer.total = calculate_total(dealer.cards)
      end
      if is_busted?(dealer.cards)
        puts "#{dealer.name} busted. #{player.name} wins!"
        player.score += 1
      else
        compare_results
      end   
    end 
  end

  def compare_results
    if player.total == dealer.total
      puts "It's a tie!"
    elsif player.total > dealer.total
      puts "#{dealer.name} has #{dealer.total} while #{player.name} has #{player.total}. #{player.name} wins!"
      player.score += 1
    elsif player.total < dealer.total
      puts "#{dealer.name} has #{dealer.total} while #{player.name} has #{player.total}. #{player.name} loses!"  
      dealer.score += 1
    end    
  end

  def show_score
    puts "--÷--÷--÷--÷--÷--÷--÷--÷--÷--÷--".center(42)    
    puts "SCORE: #{player.name} = #{player.score} | #{dealer.name} = #{dealer.score}".center(42)
    puts "--÷--÷--÷--÷--÷--÷--÷--÷--÷--÷--".center(42)    
  end

  private

  def dealer_for_today
    %w(Derrick Bianca Luna Oliver).sample
  end
end

game = Game.new.play
