def repeat_action_until_condition(action, condition)
    x = action.()
    while not condition.(x)
        x = action.()
    end
    return x
end

def input(*args)
    print(*args)
    gets.chomp
end

def ask_positive_integer(prompt="Enter a positive integer: ")
    repeat_action_until_condition(
        lambda { input(prompt) },
        lambda { |x| x.to_i.to_s == x && x.to_i >= 0 }
    )
end

puts ask_positive_integer
