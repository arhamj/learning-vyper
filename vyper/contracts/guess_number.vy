# @version ^0.3.1

secret_number: uint256
curr_balance: public(uint256)
active: public(bool)

@external
@payable
def __init__(_secret_number: uint256):
    assert msg.value == 10*(10**18)
    assert (_secret_number >= 0) and (_secret_number <= 100), "The secret number should be within 0 to 100"
    self.secret_number = _secret_number
    self.curr_balance = self.curr_balance + msg.value
    self.active = True

@external
@payable
def play(_guessed_number: uint256):
    assert self.active == True, "Contract voided"
    assert msg.value == 10**18
    if _guessed_number == self.secret_number:
        send(msg.sender, self.balance)
        self.curr_balance = 0
        self.active = False


