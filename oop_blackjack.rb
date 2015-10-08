#oop_blackjack.rb
#Gameplay: Player and Dealer, gets dealt 2 cards each: player's cards face up while dealer gets first card face up
# * Players get prompt to hit or stay, when Stay, dealer gets hit until total is at least 17. If not busted, total for both is compared to declare winner.
# Requirements: OOP, multiple decks
# Nouns: Suit, Value, Card, Deck, Players: Player and Dealer
# Behaviours: shuffle, deal, show_second_card, calculate_total, declare_winner


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
    cards.each do |card|
      if (1..10).include?(card.value.to_i)
        total += card.value.to_i
      elsif card.value == 'K' || card.value == 'Q' || card.value == 'J'
        total += 10
      elsif card.value == 'A'
        if total > 10
          total += 1
        else
          total += 11
        end
      end
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
  attr_accessor :cards
  attr_reader :name

  def initialize(name)
    @name = name 
    @cards = []
  end

  def show_cards
    puts "#{name} has the following cards: "
    puts cards
    puts "#{name} has a total of #{calculate_total(cards)}" 
  end 

  def show_first_card
    puts "#{name} has the first card: " 
    puts "#{cards[0]}"
  end
end

class Game
  include Hand
  attr_accessor :player, :dealer, :deck
  player_total = 0
  dealer_total = 0

  def initialize
    game_intro
    @deck = Deck.new
    set_number_of_decks
    @player = Player.new(@@player_name)
    @dealer = Player.new("Dealer " + @@dealer_name)
    deal_initial_cards   
  end

  def game_intro
    puts "--÷--÷--÷--÷--÷--÷--÷--÷--÷--÷--".center(42)
    puts "Welcome to BLACKJACK!".center(42)
    puts "--÷--÷--÷--÷--÷--÷--÷--÷--÷--÷--".center(42)     
    puts "What is your name?"
    @@player_name = gets.chomp
    dealer_list = %w(Derrick Bianca Luna Oliver)
    @@dealer_name = dealer_list.sample
    puts "Welcome #{@@player_name}. Your dealer for today is #{@@dealer_name}."
    puts "Let's play!"  
  end

  def set_number_of_decks
    deck.cards = deck.cards * [1, 2, 3, 4, 5, 6, 7, 8].sample
  end

  def deal_initial_cards
    player.cards = []
    dealer.cards = []
    2.times do 
      player.cards << deck.deal_card
      dealer.cards << deck.deal_card
    end
  end

  def play
    player.show_cards
    if is_blackjack?(player.cards)
      puts "#{player.name} has blackjack! #{player.name} wins!"
    else
      dealer.show_first_card
      hit_or_stay
    end
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
        player_total = calculate_total(player.cards)
        #Check for bust
        if is_busted?(player.cards)
          puts "#{player.name} busted at #{player_total}. #{player.name} loses!"
          break
        end
      elsif hit_or_stay == 's' || calculate_total(player.cards) == 21
        dealer_turn
        break      
      else
        puts 'Please type h to hit or s to stay.'
      end
    end
  end

  def dealer_turn
    dealer.show_cards
    dealer_total = calculate_total(dealer.cards)
    #Check for blackjack
    if is_blackjack?(dealer.cards)
      puts "#{dealer.name} has blackjack! #{player.name} loses!"
    else
      while dealer_total < 17
        puts "Dealing another card for dealer..."
        dealer.cards << deck.deal_card
        dealer.show_cards
        dealer_total = calculate_total(dealer.cards)
      end
      if is_busted?(dealer.cards)
        puts "#{dealer.name} busted. #{player.name} wins!"
      else
        compare_results
      end   
    end 
  end

  def compare_results
    player_total = calculate_total(player.cards)
    dealer_total = calculate_total(dealer.cards)
    if player_total == dealer_total
      puts "It's a tie!"
    elsif player_total > dealer_total
      puts "#{dealer.name} has #{dealer_total} while #{player.name} has #{player_total}. #{player.name} wins!"
    elsif player_total < dealer_total
      puts "#{dealer.name} has #{dealer_total} while #{player.name} has #{player_total}. #{player.name} loses!"  
    end    
  end
end

#Main
game = Game.new.play
