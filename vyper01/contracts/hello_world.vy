# @version ^0.3.1

greeting: String[79]
friend: String[20]
greet_friend: public(String[100])

@external
def __init__(_greeting: String[79], _friend: String[20]):
    self.greeting = _greeting
    self.friend = _friend
    self.greet_friend = concat(self.greeting, " ", self.friend)

@external
@payable
def set_greeting(_greeting: String[79]):
    assert msg.value == 10**18
    self.greeting = _greeting
    self.greet_friend = concat(self.greeting, " ", self.friend)

@external
def set_friend(_friend: String[20]):
    self.friend = _friend
    self.greet_friend = concat(self.greeting, " ", self.friend)
