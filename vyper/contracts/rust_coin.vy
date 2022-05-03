# @version ^0.3.1

NAME: constant(String[10]) = "Rust"
DECIMAL: constant(uint256) = 18

event Transfer:
    _from: indexed(address)
    _to: indexed(address)
    _value: uint256

event Approve:
    _owner: indexed(address)
    _spender: indexed(address)
    _value: uint256

_total_supply: uint256
_balances: HashMap[address, uint256]
_allowances: HashMap[address, HashMap[address, uint256]]
_minted: bool
_minter: address

@external
def __init__():
   self._minter = msg.sender
   self._minted = False

@external
def mint(_to: address, _t_supply: uint256) -> bool:
    assert msg.sender == self._minter, 'Only the owner can mint'
    assert self._minted == False, 'Token already minted'
    self._total_supply = _t_supply * 10 ** DECIMAL
    self._balances[_to] = self._total_supply
    self._minted = True
    log Transfer(ZERO_ADDRESS, _to, self._total_supply)
    return True

@external
@view
def name() -> String[10]:
    return NAME

@external
@view
def totalSupply() -> uint256:
    return self._total_supply

@external
@view
def balanceOf(_address: address) -> uint256:
    return self._balances[_address]

@internal
def _approve(_owner: address, _spender: address, _amount: uint256):
    assert _owner != ZERO_ADDRESS
    assert _spender != ZERO_ADDRESS
    self._allowances[_owner][_spender] = _amount
    log Approve(_owner, _spender, _amount)

@internal
def _transfer(_from: address, _to: address, _amount: uint256):
    assert self._balances[_from] >= _amount, 'Insufficient funds'
    assert _from != ZERO_ADDRESS
    assert _to != ZERO_ADDRESS
    self._balances[_from] -= _amount
    self._balances[_to] += _amount
    log Transfer(_from, _to, _amount)

@external
def transfer(_to: address, _amount: uint256) -> bool:
    self._transfer(msg.sender, _to, _amount)
    return True

@external
def approve(_spender: address, _amount: uint256) -> bool:
    self._approve(msg.sender, _spender, _amount)
    return True

@external
def transferFrom(_owner: address, _to: address, _amount: uint256) -> bool:
    assert self._allowances[_owner][msg.sender] >= _amount, 'Insufficient allowances'
    self._transfer(_owner, _to, _amount)
    self._allowances[_owner][msg.sender] -= _amount
    return True

@external
def increaseAllowance(_spender: address, _amount_increased: uint256) -> bool:
    self._approve(msg.sender, _spender, self._allowances[msg.sender][_spender] + _amount_increased)
    return True

@external
def decreaseAllowance(_spender: address, _amount_decreased: uint256) -> bool:
    assert self._allowances[msg.sender][_spender] >= _amount_decreased, 'Negative allowance not allowed'
    self._approve(msg.sender, _spender, self._allowances[msg.sender][_spender] - _amount_decreased)
    return True

@external
@view
def allowance(_owner: address, _spender: address) -> uint256:
    return self._allowances[_owner][_spender]
    
@external
@view
def decimals() -> uint256:
    return DECIMAL