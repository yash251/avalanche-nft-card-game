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

    function getAllBattles() public view returns (Battle[] memory) {
        return battles;
    }

    function updateBattle(string memory _name, Battle memory _newBattle)
        private
    {
        require(isBattle(_name), "Battle doesn't exist");
        battles[battleInfo[_name]] = _newBattle;
    }

    // events
    event NewPlayer(address indexed owner, string name);
    event NewBattle(
        string battleName,
        address indexed player1,
        address indexed player2
    );
    event BattleEnded(
        string battleName,
        address indexed winner,
        address indexed loser
    );
    event BattleMove(string indexed battleName, bool indexed isFirstMove);
    event NewGameToken(
        address indexed owner,
        uint256 id,
        uint256 attackStrength,
        uint256 defenseStrength
    );
    event RoundEnded(address[2] damagedPlayers);

    function initialize() private {
        gameTokens.push(GameToken("", 0, 0, false));
        players.push(Player(address(0), "", 0, 0, false));
        battles.push(
            Battle(
                BattleStatus.PENDING,
                bytes32(0),
                "",
                [address(0), address(0)],
                [0, 0],
                address(0)
            )
        );
    }

    /// @dev Initializes the contract by setting a `metadataURI` to the token collection
    /// @param _metadataURI baseURI where token metadata is stored
    constructor(string memory _metadataURI) ERC1155(_metadataURI) {
        baseURI = _metadataURI;
        initialize();
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    /// @dev Registers a player
    /// @param _name player name; set by player
    function registerPlayer(string memory _name, string memory _gameTokenName)
        external
    {
        require(!isPlayer(msg.sender), "Player already registered");
        uint256 _id = players.length;
        players.push(Player(msg.sender, _name, 10, 25, false));
        playerInfo[msg.sender] = _id;
        createRandomGameToken(_gameTokenName);
        emit NewPlayer(msg.sender, _name);
    }

    /// @dev internal function to generate random number; used for Battle Card Attack and Defense Strength
    function _createRandomNum(uint256 _max, address _sender)
        internal
        view
        returns (uint256 randomValue)
    {
        uint256 randomNum = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, _sender)
            )
        );

        randomValue = randomNum % _max;
        if (randomValue == 0) {
            randomValue = _max / 2;
        }

        return randomValue;
    }

    /// @dev internal function to create a new Battle Card
    function _createGameToken(string memory _name)
        internal
        returns (GameToken memory)
    {
        uint256 randAttackStrength = _createRandomNum(
            MAX_ATTACK_DEFEND_STRENGTH,
            msg.sender
        );
        uint256 randDefenseStrength = MAX_ATTACK_DEFEND_STRENGTH -
            randAttackStrength;

        uint8 randId = uint8(
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                100
        );
        randId = randId % 6;
        if (randId == 0) {
            randId++;
        }

        GameToken memory newGameToken = GameToken(
            _name,
            randId,
            randAttackStrength,
            randDefenseStrength
        );

        uint256 _id = gameTokens.length;
        gameTokens.push(newGameToken);
        playerTokenInfo[msg.sender] = _id;

        _mint(msg.sender, randId, 1, "0x0");
        totalSupply++;

        emit NewGameToken(
            msg.sender,
            randId,
            randAttackStrength,
            randDefenseStrength
        );
        return newGameToken;
    }

    /// @dev Creates a new game token
    /// @param _name game token name; set by player
    function createRandomGameToken(string memory _name) public {
        require(!getPlayer(msg.sender).inBattle, "Player is in a battle");
        require(isPlayer(msg.sender), "Please register player first");

        _createGameToken(_name);
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    /// @dev Creates a new battle
    /// @param _name battle name; set by player
    function createBattle(string memory _name)
        external
        returns (Battle memory)
    {
        require(isPlayer(msg.sender), "Please Register Player First"); // Require that the player is registered
        require(!isBattle(_name), "Battle already exists!"); // Require battle with same name should not exist

        bytes32 battleHash = keccak256(abi.encode(_name));

        Battle memory _battle = Battle(
            BattleStatus.PENDING, // Battle pending
            battleHash, // Battle hash
            _name, // Battle name
            [msg.sender, address(0)], // player addresses; player 2 empty until they joins battle
            [0, 0], // moves for each player
            address(0) // winner address; empty until battle ends
        );

        uint256 _id = battles.length;
        battleInfo[_name] = _id;
        battles.push(_battle);

        return _battle;
    }

    /// @dev Player joins battle
    /// @param _name battle name; name of battle player wants to join
    function joinBattle(string memory _name) external returns (Battle memory) {
        Battle memory _battle = getBattle(_name);

        require(
            _battle.battleStatus == BattleStatus.PENDING,
            "Battle already started!"
        ); // Require that battle has not started
        require(
            _battle.players[0] != msg.sender,
            "Only player 2 can join a battle"
        ); // Require that player 2 is joining the battle
        require(!getPlayer(msg.sender).inBattle, "Already in battle"); // Require that player is not already in a battle

        _battle.battleStatus = BattleStatus.STARTED;
        _battle.players[1] = msg.sender;
        updateBattle(_name, _battle);

        players[playerInfo[_battle.players[0]]].inBattle = true;
        players[playerInfo[_battle.players[1]]].inBattle = true;

        emit NewBattle(_battle.name, _battle.players[0], msg.sender); // Emits NewBattle event
        return _battle;
    }

    // Read battle move info for player 1 and player 2
    function getBattleMoves(string memory _battleName)
        public
        view
        returns (uint256 P1Move, uint256 P2Move)
    {
        Battle memory _battle = getBattle(_battleName);

        P1Move = _battle.moves[0];
        P2Move = _battle.moves[1];

        return (P1Move, P2Move);
    }

    function _registerPlayerMove(
        uint256 _player,
        uint8 _choice,
        string memory _battleName
    ) internal {
        require(
            _choice == 1 || _choice == 2,
            "Choice should be either 1 or 2!"
        );
        require(
            _choice == 1 ? getPlayer(msg.sender).playerMana >= 3 : true,
            "Mana not sufficient for attacking!"
        );
        battles[battleInfo[_battleName]].moves[_player] = _choice;
    }
}
