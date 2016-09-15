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

# Constants containing all consonants and vowels in the latin alphabet + some
# extra non-latin letters. The number after each letter represents how common
# a letter should be
CONS_LATIN = ['b']*100 + ['c']*100 + ['d']*100 + ['f']*100 + ['g']*100 + ['h']*100 + ['j']*100 + ['k']*100 + ['l']*100 + ['m']*100 + ['n']*100 + ['p']*100 + ['q']*85 + ['r']*100 + ['s']*100 + ['t']*100 + ['v']*100 + ['w']*50 + ['x']*75 + ['z']*50
VOWS_LATIN = ['a']*100 + ['e']*100 + ['i']*100 + ['o']*100 + ['u']*100 + ['y']*75
VOWS_EXTRA = ['ĳ']*75 + ['å']*100 + ['ä']*100 + ['ö']*100 + ['ø']*75 + ['æ']*60

# Banned combinations which are hard to pronounce or look weird
BANNED_COMBOS = [['g','j'],['f','k'],['b','k'],['q','p'],['w','q'],['q','g'],['x','x'],['q', 'q'],['d','b']]

def getRandomVowel
    # Only 10% chance to generate random "non-latin" vowel
    if rand() <= 0.1
        return VOWS_EXTRA.sample
    else
        return VOWS_LATIN.sample
    end
end

def getRandomVowelNoDuplicates(str:)
    # Generate a random vowel and if it a non-latin vowel
    # then we only use it if it has not been previously used in str
    vowel = getRandomVowel
    while VOWS_EXTRA.include? vowel and str.include? vowel
        vowel = getRandomVowel
    end
    return vowel
end

def getRandomConsonante
    return CONS_LATIN.sample
end

def getLastCharactersFromString(str:, numChars:)
    return Unicode::downcase (str[-numChars, numChars].to_s)
end

def isVowel(chr:)
    return ((VOWS_LATIN.include? (Unicode::downcase chr)) or
            (VOWS_EXTRA.include? (Unicode::downcase chr)))
end

def isConsonant(chr:)
    return (CONS_LATIN.include? (Unicode::downcase chr))
end

def generateLetter(currentName:)
    if currentName.empty?
        # We have a 60% chance to generate a vowel as the first letter
        if rand() <= 0.6
            return Unicode::upcase getRandomVowel
        else
            return Unicode::upcase getRandomConsonante
        end
    end
    
    if currentName.length < 2
        # Append random vowel or consonant in beginning to
        # prevent program from crashing if length of name is
        # less than 2
        if rand() <= 0.5
            chr = getRandomVowelNoDuplicates(str: currentName)
        else
            chr = getRandomConsonante
        end
        lastCharacters = chr + getLastCharactersFromString(str: currentName.join(""), numChars: 1)
    else
        lastCharacters = getLastCharactersFromString(str: currentName.join(""), numChars: 2)
    end
    # Apply rules
    #
    # 30% chance that there will be a double vowel
    # unless the last vowel is a non-latin vowel
    if isConsonant(chr: lastCharacters[0]) and isVowel(chr: lastCharacters[1])        
        if rand() <= 0.3 and (VOWS_LATIN.include? lastCharacters[1])
            return lastCharacters[1]
        end
    end
    # No more than 2 consonants in a row
    if isConsonant(chr: lastCharacters[0]) and isConsonant(chr: lastCharacters[1])
        # Exception for 'chr' and 'sch'
        cons = getRandomConsonante
        if (lastCharacters == "ch" and cons == 'r') or
           (lastCharacters == "sc" and cons == 'h')
            return cons
        else
            return getRandomVowelNoDuplicates(str: currentName)
        end
    end
    # No more than 2 vowels in a row
    if isVowel(chr: lastCharacters[0]) and isVowel(chr: lastCharacters[1])
        return getRandomConsonante
    end
    # If no condition above is met we have a 40% chance to generate a vowel
    # and a 60% chance to generate a consonante
    if rand() <= 0.4
        return getRandomVowelNoDuplicates(str: currentName)
    else
        # Prevent weird combinations like gj, fk or bk.
        cons = getRandomConsonante
        for combo in BANNED_COMBOS
          while (lastCharacters[1] == combo[0] and cons == combo[1])
            cons = getRandomConsonante
          end
        end
        return cons
    end
end

def generateRandomName
    # Generate a number between 3 and 12
    # The reason we have 9 instead of 12
    # is because rand()*12 could give 12
    # and when we add 3, we would get 15
    # which would be greater than 12 (9+3 == 12)
    nameLength = (rand()*9+3).round

    # Create new list and initialize counter to 0
    name = []
    counter = 0

    # We loop nameLength times
    # So if nameLength equals 9 we loop
    # 9 times. We put the result of
    # generateLetter into our name list
    # at position counter. Counter will
    # be increased AFTER we put the result
    # into our name list
    currentName = ""
    nameLength.times do        
        name[counter] = generateLetter(currentName: currentName)
        currentName = name
        counter = counter + 1
    end

    # Convert the list of characters to a string using join("")
    return name.join("")
end

def askForNumber
    begin
        puts "Enter number of names to generate"
        num = gets.chomp
    end while num.to_i.to_s != num # check if num is a valid number
    return num.to_i
end

# Generate amount of names the user enters
num = askForNumber
num.times do
    puts generateRandomName
end
