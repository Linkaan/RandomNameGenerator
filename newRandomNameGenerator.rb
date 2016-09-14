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

CONS_LATIN = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'z']
VOWS_LATIN = ['a', 'e', 'i', 'o', 'u', 'y']
VOWS_EXTRA = ['ĳ', 'å', 'ä', 'ö', 'ø', 'æ']
BANNED_COMBOS = [['g','j'],['f','k'],['b','k'],['l','d'],['q','p'],['w','q']]

def getRandomVowel
    # Only 10% chance to generate random "non-latin" vowel
    if rand() <= 0.1
        return VOWS_EXTRA.sample
    else
        return VOWS_LATIN.sample
    end
end

def getRandomVowelNoDuplicates(str:)
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
        if rand() <= 0.6
            return Unicode::upcase getRandomVowel
        else
            return Unicode::upcase getRandomConsonante
        end
    end
    
    if currentName.length < 2
        # Append random vowel or consonant in beginning to
        # prevent program from crashing
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
    # 30% chance that there will be a double vowel    
    if isConsonant(chr: lastCharacters[0]) and isVowel(chr: lastCharacters[1])        
        if rand() <= 0.3
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
    return name.join("")
end

def askForNumber
    begin
        puts "Enter number of names to generate"
        num = gets.chomp
    end while num.to_i.to_s != num
    return num.to_i
end

num = askForNumber
num.times do
    puts generateRandomName
end
