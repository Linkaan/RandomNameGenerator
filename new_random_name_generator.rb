# Inte mer än två konsonanter i rad (undantag 'Chr' och 'Sch')
# För varje vokal används mellan 1 till 2 konsonanter
# 30% att en dubbelvokal används (e.g ee, aa, ii)
# Första bokstaven i namnet har 60% att vara vokal
# Konsonanterna g, j och f, k och b, k kan inte vara tillsammans
# Ett namn är mellan 3-12 bokstäver långt
# Latinska alfabetet + följande bokstäver 'ĳ', 'å', 'ä', 'ö', 'Ø', 'Æ'
# Bokstäver som inte tillhör latinska alfabetet har bara en 10% att användas
# Inga dubletter av ovanstående icke-latinska bokstäver
# Om inga andra regler kan tillämpas är det en 40% chans att generera en vokal
# och en 60% chans att generera en konsonant

require 'unicode'

# Set rng seed for debugging purposes, a constant will make the random number
# stream much more deterministic (i.e it will be in the same order every runtime).
# If a value of 0 is used, srand will not be called and is ruby will use use a more
# undeterministic random number stream which varies every runtime
SEED = 1

# Constants containing all consonants and vowels in the latin alphabet + some
# extra non-latin letters. Their weight is a number which represents how common
# a letter will be (i.e how likely it is to be chosen at random)
WEIGHTS = Hash.new 100 # 100 is default
[ ['w', 50], ['x', 75], ['q', 85], ['y', 75], ['ĳ', 75], ['ø', 75], ['æ', 60] ].each{ |ch, w| WEIGHTS[ch] = w}
CONS_LATIN = ('a'..'z').reject{|x| "aeiouy".include?(x)}.map{|x| [x]*WEIGHTS[x]}.flatten
VOWS_LATIN = "aeiouy".split("").map{|x| [x]*WEIGHTS[x]}.flatten
VOWS_EXTRA = "ĳåäöøæ".split("").map{|x| [x]*WEIGHTS[x]}.flatten

# Banned combinations which are hard to pronounce or look weird
BANNED_COMBOS = ["gj", "fk", "bk", "qp", "wq", "qg", "xx", "qq", "db"]
# Exceptions for combinations with three consonants in a row
ALLOWED_COMBOS = ["chr", "sch"]

def random_vowel
    (rand() < 0.1 ? VOWS_EXTRA : VOWS_LATIN).sample
end

def repeat_action_until_condition(action, condition)
    x = action.()
    while not condition.(x)
        x = action.()
    end
    return x
end

def random_unique_vowel(str)
    # Generate a random vowel and if it a non-latin vowel
    # then we only use it if it has not been previously used in str
    repeat_action_until_condition(
        lambda { random_vowel },
        lambda { |x| not (VOWS_EXTRA.include? x and str.include? x) }
    )
end

def random_consonant
    CONS_LATIN.sample
end

def random_valid_consonant(last_chars)
    # Prevent weird combinations like gj, fk or bk.
    repeat_action_until_condition(
        lambda { random_consonant },
        lambda { |x| not BANNED_COMBOS.include? (last_chars[1] + x) }
    )
end

def get_last_chars_from_str(str, num_chars)
    Unicode::downcase (str[-num_chars, num_chars].to_s)
end

def is_vowel(chr)
    (VOWS_LATIN.include? (Unicode::downcase chr)) or
    (VOWS_EXTRA.include? (Unicode::downcase chr))
end

def is_consonant(chr)
    (CONS_LATIN.include? (Unicode::downcase chr))
end

def apply_double_vowel(last_chars, result)
    # 30% chance that there will be a double vowel
    # unless the last vowel is a non-latin vowel
    if is_consonant(last_chars[0]) and is_vowel(last_chars[1])
        if rand() < 0.3 and VOWS_LATIN.include? last_chars[1]
            result.replace last_chars[1]
            return true
        end
    end
    return false
end

def apply_limit_consonants(current_name, last_chars, result)
    # No more than 2 consonants in a row
    if is_consonant(last_chars[0]) and is_consonant(last_chars[1])
        # Exception for allowed 3 consonant combinations like chr and sch
        cons = random_consonant
        if ALLOWED_COMBOS.include? (last_chars + cons)
            result.replace cons            
        else
            result.replace random_unique_vowel(current_name)            
        end
        return true
    end
    return false
end

def apply_limit_vowels(last_chars, result)
    # No more than 2 vowels in a row
    if is_vowel(last_chars[0]) and is_vowel(last_chars[1])
        result.replace random_consonant
        return true
    end
    return false
end

def generate_letter(current_name)
    if current_name.empty?
        return Unicode::upcase (rand() < 0.6 ? random_vowel : random_consonant)
    end
    
    if current_name.length < 2
        # Append random vowel or consonant in beginning to prevent
        # program from crashing if length of name is less than 2
        chr = [random_unique_vowel(current_name), random_consonant].sample
        last_chars = chr + get_last_chars_from_str(current_name.join, 1)
    else
        last_chars = get_last_chars_from_str(current_name.join, 2)
    end

    # Apply all the rules defined in header of program
    result = ""
    if 
        apply_double_vowel(last_chars, result) or
        apply_limit_consonants(current_name, last_chars, result) or
        apply_limit_vowels(last_chars, result)
        return result
    else
        # If non of the rules can be applied above we generate a random
        # vowel or consonant
        return (rand() < 0.4 ? random_unique_vowel(current_name) : random_valid_consonant(last_chars))
    end 
end

def generate_random_name
    # Generate a number between 3 and 12 and store it in length
    length = (3..12).to_a.sample
    name = []
    length.times {name << generate_letter(name)}
    return name.join
end

def input(*args)
    print(*args)
    gets.chomp
end

def ask_positive_integer(prompt)
    repeat_action_until_condition(
        lambda { input(prompt) },
        lambda { |x| x.to_i.to_s == x && x.to_i >= 0 }
    )
end

if SEED != 0
    srand SEED
end

# Generate amount of names the user enters
num = ask_positive_integer("Amount of names to generate: ").to_i
num.times { puts generate_random_name }
