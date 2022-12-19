// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

/// @title AVAXGods
/// @notice This contract handles the token management and battle logic for the AVAXGods game
/// @notice Version 1.0.0

contract AVAXGods is ERC1155, Ownable, ERC1155Supply {
    string public baseURI; // Base URI where token metadata is stored
    uint256 public totalSupply; // Total supply of tokens
    uint256 public constant DEVIL = 0;
    uint256 public constant GRIFFIN = 1;
    uint256 public constant FIREBIRD = 2;
    uint256 public constant KAMO = 3;
    uint256 public constant KUKULKAN = 4;
    uint256 public constant CELESTION = 5;

    uint256 public constant MAX_ATTACK_DEFEND_STRENGTH = 10;

    enum BattleStatus {
        PENDING,
        STARTED,
        ENDED
    }

    /// @dev GameToken struct to store player token information
    struct GameToken {
        string name; /// @param name battle card name; set by player
        uint256 id; /// @param id battle card token id; will be randomly generated
        uint256 attackStrength; /// @param attackStrength battle card attack; generated randomly
        uint256 defenseStrength; /// @param defenseStrength battle card defense; generated randomly
    }

    /// @dev Player struct to store player info
    struct Player {
        address playerAddress; /// @param playerAddress player wallet address
        string playerName; /// @param playerName player name; set by player during registration
        uint256 playerMana; /// @param playerMana player mana; affected by battle results
        uint256 playerHealth; /// @param playerHealth player health; affected by battle results
        bool inBattle; /// @param inBattle boolean to indicate if a player is in battle
    }

    /// @dev Battle struct to store battle info
    struct Battle {
        BattleStatus battleStatus; /// @param battleStatus enum to indicate battle status
        bytes32 battleHash; /// @param battleHash a hash of the battle name
        string name; /// @param name battle name; set by player who creates battle
        address[2] players; /// @param players address array representing players in this battle
        uint8[2] moves; /// @param moves uint array representing players' move
        address winner; /// @param winner winner address
    }

    mapping(address => uint256) public playerInfo; // mapping of player addresses to player index in the players array
    mapping(address => uint256) public playerTokenInfo; // mapping of player addresses to player token index in the gameTokens array
    mapping(string => uint256) public battleInfo; // mapping of battle names to battle index in the battles array

    Player[] public players; // array of players
    GameToken[] public gameTokens; // array of game tokens
    Battle[] public battles; // array of battles

    function isPlayer(address addr) public view returns (bool) {
        if (playerInfo[addr] == 0) {
            return false;
        } else {
            return true;
        }
    }

    function getPlayer(address addr) public view returns (Player memory) {
        require(isPlayer(addr), "Player doesn't exist!");
        return players[playerInfo[addr]];
    }

    function getAllPlayers() public view returns (Player[] memory) {
        return players;
    }

    function isPlayerToken(address addr) public view returns (bool) {
        if (playerTokenInfo[addr] == 0) {
            return false;
        } else {
            return true;
        }
    }

    function getPlayerToken(address addr)
        public
        view
        returns (GameToken memory)
    {
        require(isPlayerToken(addr), "Player token doesn't exist!");
        return gameTokens[playerTokenInfo[addr]];
    }

    function getAllPlayerTokens() public view returns (GameToken[] memory) {
        return gameTokens;
    }

    // Battle getter function
    function isBattle(string memory _name) public view returns (bool) {
        if (battleInfo[_name] == 0) {
            return false;
        } else {
            return true;
        }
    }

    function getBattle(string memory _name)
        public
        view
        returns (Battle memory)
    {
        require(isBattle(_name), "Battle doesn't exist!");
        return battles[battleInfo[_name]];
    }
}
