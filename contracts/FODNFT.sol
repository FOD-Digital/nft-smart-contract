// SPDX-License-Identifier: MIT
// GOERLI : 0x0d69Ed2c842AacC557e0bC38F16463600Ddc45aE
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FODNFT is ERC1155, Ownable { 
    using SafeMath for uint256;
    
    uint256 public constant MAX_SUPPLY_PRESTIGE = 100;
    uint256 public constant MAX_SUPPLY_ORDINARY = 900;
    uint256 public constant TOKEN_ID_PRESTIGE = 1;
    uint256 public constant TOKEN_ID_ORDINARY = 2;

    uint256 public MAX_PER_WALLET = 5;
    uint256 public MINT_PRICE = 0.000001 ether; 
    
    uint256 public supplyPrestige = 1;
    uint256 public supplyOrdinary = 1;

    mapping(address => uint256) public _ownersPackCount;
    mapping(address => uint256) public _lastMintedRarity;

    constructor() ERC1155("https://bafybeic2h4dplssisykqurcnc5e3a4mk2kdac7n3bn6iziwzx2b3iwoupi.ipfs.nftstorage.link/{id}.json") {
        _mint(msg.sender, TOKEN_ID_PRESTIGE, 1, "");
        _mint(msg.sender, TOKEN_ID_ORDINARY, 1, "");
    }

    function mintPack() external payable {
        require(_ownersPackCount[msg.sender] + 1 <= MAX_PER_WALLET, "exceed max supply of per wallet amount");

        uint256 randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % 10 + 1;

        if (randomNumber == 1) {
            require(msg.value == MINT_PRICE, "Mint: Incorrect payment");
            require(supplyPrestige + 1 <= MAX_SUPPLY_PRESTIGE, "Mint: Max supply reached");
            _mint(msg.sender, TOKEN_ID_PRESTIGE, 1, "");
            supplyPrestige++;
        } else {
            require(msg.value == MINT_PRICE, "Mint: Incorrect payment");
            require(supplyOrdinary + 1 <= MAX_SUPPLY_ORDINARY, "Mint: Max supply reached");
            _mint(msg.sender, TOKEN_ID_ORDINARY, 1, "");
            supplyOrdinary++;
        }

        _ownersPackCount[msg.sender] += 1;
        _lastMintedRarity[msg.sender] = randomNumber;
    }

    function getLastMintedRarity(address user) external view returns (uint256) {
        return _lastMintedRarity[user];
    }

    function uri(uint256 _id) override public view returns (string memory) {
        return string(
            abi.encodePacked("https://bafybeic2h4dplssisykqurcnc5e3a4mk2kdac7n3bn6iziwzx2b3iwoupi.ipfs.nftstorage.link/",
            Strings.toString(_id), ".json"));
    }  

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function updateMaxPerWallet(uint256 newLimit) external onlyOwner {
        MAX_PER_WALLET = newLimit;
    }

    function changePrice(uint256 price) external onlyOwner {
        MINT_PRICE = price;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}

