import pytest
from brownie import Wei, accounts, guess_number_2

owner_account_index = 6
game_creator_account_index = 8
player_account_index = 9

@pytest.fixture
def guess_number():
    guess_number = guess_number_2.deploy({'from': accounts[owner_account_index]})
    guess_number.create_game(13, {'from': accounts[game_creator_account_index], 'value': '10 ether'})
    return guess_number

def test_wrong_guess(guess_number):
    prev_game_balance = guess_number.get_game_balance(0)
    prev_player_balance = accounts[player_account_index].balance()
    prev_guess_count = guess_number.get_game_guesses(0)
    guess_number.play_game(0, 8, {'from': accounts[player_account_index], 'value': '1 ether'})
    assert guess_number.get_game_balance(0) == prev_game_balance + Wei('1 ether'), 'Incorrect game balance'
    assert accounts[player_account_index].balance() == prev_player_balance - Wei('1 ether'), 'Incorrect player balance'
    assert guess_number.get_game_guesses(0) == prev_guess_count + 1, "Incorrect game guesses"
    assert guess_number.is_game_active(0) == True
    return

def test_right_guess(guess_number):
    prev_game_balance = guess_number.get_game_balance(0)
    prev_player_balance = accounts[player_account_index].balance()
    prev_guess_count = guess_number.get_game_guesses(0)
    prev_contract_owner_balance = accounts[owner_account_index].balance()
    guess_number.play_game(0, 13, {'from': accounts[player_account_index], 'value': '1 ether'})
    assert guess_number.get_game_balance(0) == 0, 'Game balance not reset'
    assert accounts[owner_account_index].balance() == prev_contract_owner_balance + (prev_game_balance + Wei('1 ether')) / 100, "Incorrect commission"
    print("bal1", accounts[player_account_index].balance())
    print("bal2", prev_player_balance - Wei('1 ether') + (prev_game_balance + Wei('1 ether')) / 100)
    print("bal3", prev_player_balance - Wei('1 ether'))
    print("bal4", prev_game_balance + Wei('1 ether') / 100)
    assert accounts[player_account_index].balance() == prev_player_balance - Wei('1 ether') + ((prev_game_balance + Wei('1 ether'))*99) / 100, 'Incorrect player balance'
    assert guess_number.get_game_guesses(0) == prev_guess_count + 1, "Incorrect game guesses"
    assert guess_number.is_game_active(0) == False
    return