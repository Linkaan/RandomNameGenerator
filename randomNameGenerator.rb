# Inte mer än två konsonanter i rad (undantag 'Chr' och 'Sch')
# För varje vokal används mellan 1 till 2 konsonanter
# 30% att en dubbelvokal används (e.g ee, aa, ii)
# Första bokstaven i namnet har 60% att vara vokal
# Konsonanterna g, j och f, k och b, k kan inte vara tillsammans
# Ett namn är mellan 3-12 bokstäver långt
# Latinska alfabetet + följande bokstäver 'ĳ', 'å', 'ä', 'ö', 'Ø', 'Æ'
# Bokstäver som inte tillhör latinska alfabetet har bara en 10% att användas

consLatin = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'z']
vowsLatin = ['a', 'e', 'i', 'o', 'u', 'y']
vowsExtra = ['ĳ', 'å', 'ä', 'ö', 'Ø', 'Æ']

def getRandomVowel
    # Only 10% chance to generate random "non-latin" vowel
    if rand() <= 0.1
        return vowsExtra.sample
    else
        return vowsLatin.sample
    end
end

def getRandomConsonante
    return consLatin.sample
end

def getLastCharactersFromString(str:, numChars:)
    return str[-numChars, numChars]
end

def isVowel(chr:)
    return vowsLatin.include? chr or vowsExtra.include? chr
end

def isConsonant(chr:)
    return !isVowel(chr: chr)
end

def generateLetter(currentName:)
    if currentName.length == 0
        if rand() <= 0.6
            return getRandomVowel
        else
            return getRandomConsonante
        end
    end
    lastCharacters = getLastCharactersFromString(str: currentName, numChars:2).downcase
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
            return getRandomVowel
        end
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
        name[counter] = generateLetter(lastLetter: currentName)
        currentName = name
        counter = counter + 1
    end
end
