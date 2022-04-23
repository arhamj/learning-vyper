# @version ^0.3.1

event GameCreated:
    owner: indexed(address)
    game_index: uint256

event GameSolved:
    solver: indexed(address)
    game_index: uint256

event GamePlayed:
    solver: indexed(address)
    game_index: uint256
    guess_count: uint256

struct game:
    game_owner: address
    secret_number: uint256
    game_balance: uint256
    guess_count: uint256
    is_active: bool

curr_id: uint256
game_index: HashMap[uint256, game]
contract_owner: address

@external
def __init__():
    self.contract_owner = msg.sender
    self.curr_id = 0

@external
@payable
def create_game(_secret_number: uint256):
    assert msg.value == 10*(10**18), "Min. of 10 Ether required to create game"
    assert (_secret_number >= 0) and (_secret_number <= 100), "The secret number should be within 0 to 100"
    self.game_index[self.curr_id].game_owner = msg.sender
    self.game_index[self.curr_id].game_balance = self.game_index[self.curr_id].game_balance  + msg.value
    self.game_index[self.curr_id].secret_number = _secret_number
    self.game_index[self.curr_id].guess_count = 0
    self.game_index[self.curr_id].is_active = True
    self.curr_id = self.curr_id + 1
    log GameCreated(msg.sender, self.curr_id - 1)

@external
@view
def get_game_balance(_game_id: uint256) -> uint256:
    return self.game_index[_game_id].game_balance

@external
@view
def get_game_guesses(_game_id: uint256) -> uint256:
    return self.game_index[_game_id].guess_count

@external
@view
def is_game_active(_game_id: uint256) -> bool:
    return self.game_index[_game_id].is_active

@external
@payable
def play_game(_game_id: uint256, _guessed_number: uint256) -> bool:
    assert msg.value == 10**18, "1 Ether required to make guess"
    assert msg.sender != self.game_index[_game_id].game_owner
    assert self.game_index[_game_id].is_active == True
    self.game_index[_game_id].game_balance = self.game_index[_game_id].game_balance + msg.value
    self.game_index[_game_id].guess_count = self.game_index[_game_id].guess_count + 1
    if _guessed_number == self.game_index[_game_id].secret_number:
        send(msg.sender, (self.game_index[_game_id].game_balance * 99)/100)
        send(self.contract_owner, (self.game_index[_game_id].game_balance * 1)/100)
        self.game_index[_game_id].game_balance = 0
        self.game_index[_game_id].is_active = False
        log GameSolved(msg.sender, _game_id)
        return True
    else:
        if self.game_index[_game_id].guess_count == 10:
            send(self.game_index[_game_id].game_owner, (self.game_index[_game_id].game_balance * 99)/100)
            send(self.contract_owner, (self.game_index[_game_id].game_balance * 1)/100)
            self.game_index[_game_id].game_balance = 0
            self.game_index[_game_id].is_active = False
    log GamePlayed(msg.sender, _game_id, self.game_index[_game_id].guess_count)
    return False
    