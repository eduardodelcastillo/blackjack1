#blackjack.rb 

# A way to deal cards with the four suits and 13 in each suit
# Gameplay:
  # Deal player first, then deal a card to dealer 
  # Deal 2nd card to player and to dealer, 1st card of dealer face up
  # Hit or Stay for the player 
  # Once Player stay, Dealer opens second card. Hit until total is at least 17.

def calculate_total(cards)
  total = 0
  cards.each do |c|
    if (1..10).include?(c.last.to_i)
      total += c.last.to_i
    elsif c.last == 'K' || c.last == 'Q' || c.last == 'J'
      total += 10
    elsif c.last == 'A'
      if total > 10
        total += 1
      else
        total += 11
      end
    end
  end
  total
end

puts "-------------------------BLACKJACK-----------------------"
puts "What is your name? "
player_name = gets.chomp
puts "#{player_name}, welcome to the Blackjack game!"

#cards 
cards = %w(2 3 4 5 6 7 8 9 10 J Q K A)
suits = %w(Spade Club Heart Diamond)
deck = suits.product(cards)
number_of_deck = %w(1 2 3 4 5 6 7 8).sample.to_i
puts "Number of card decks used for this game: #{number_of_deck}"
puts "----------------------------------------------------------"
number_of_deck.times { deck += deck }
deck.shuffle!

#Gameplay
begin
#flag
stay = false

#Dealing cards 
player_cards = []
dealer_cards = []
player_cards << deck.pop
dealer_cards << deck.pop
#2nd cards
player_cards << deck.pop
dealer_cards << deck.pop 

puts "#{player_name}'s cards are #{player_cards}"
puts "Dealer's first card is #{dealer_cards.first}"

player_total = calculate_total(player_cards)
puts "#{player_name}'s total is #{player_total}." 
#Check for blackjack
if player_total == 21
  puts "Blackjack! #{player_name} wins!"
else #do the hit or stay routine
  begin   
    puts "Does #{player_name} want to hit or stay? (h or s)"
    loop do
      hit_or_stay = gets.chomp.downcase
      if hit_or_stay == 'h'
        player_cards << deck.pop
        puts "#{player_name}'s cards are #{player_cards}"        
        player_total = calculate_total(player_cards)
        puts "#{player_name}'s total is #{player_total}." 
        #Check for bust
        if player_total > 21 
          puts "#{player_name} busted at #{player_total}. Sorry #{player_name} loses!"
        end
        break
      elsif hit_or_stay == 's'
        stay = true 
        break      
      else
        puts 'Please type h to hit or s to stay.'
      end
    end
  end until stay || player_total >= 21 
end

  if stay || (player_total == 21 && player_cards.length > 2)
    #Evaluate dealer's card
    puts "Dealer's cards are #{dealer_cards}"
    dealer_total = calculate_total(dealer_cards)
    puts "Dealer's total is #{dealer_total}."
    while dealer_total < 17
      puts "Dealing another card for dealer..."
      dealer_cards << deck.pop
      puts "Dealer's cards are #{dealer_cards}"
      dealer_total = calculate_total(dealer_cards)
      puts "Dealer's total is #{dealer_total}."
    end 
    #Evaluate result
    if dealer_total > 21
      puts "Dealer busted at #{dealer_total}. #{player_name} wins!"
    elsif dealer_total < player_total
      puts "#{player_name} wins! Dealer has #{dealer_total} while #{player_name} have #{player_total}."
    elsif dealer_total > player_total
      puts "#{player_name} loses! Dealer has #{dealer_total} while #{player_name} have #{player_total}."
    elsif dealer_total == player_total 
      puts "It's a tie!"
    end 
  end
  puts "Does #{player_name} want to play again? (y or n)"
  play_again = gets.chomp.downcase
end until play_again != 'y'


