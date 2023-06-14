// SPDX-License-Identifier: MIT
// GOERLI : 0x0A0C24E401DccF48a294B5F21943C1EDAA816A2e
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

    mapping(address => uint256) public _owners;

    constructor() ERC1155("https://bafybeic2h4dplssisykqurcnc5e3a4mk2kdac7n3bn6iziwzx2b3iwoupi.ipfs.nftstorage.link/{id}.json") {
        _mint(msg.sender, TOKEN_ID_PRESTIGE, 1, "");
        _mint(msg.sender, TOKEN_ID_ORDINARY, 1, "");
    }

    function mintPack(uint256 amount) external payable returns (uint256) {
        require(amount > 0, "quantity of tokens cannot be less than or equal to 0");
        require(_owners[msg.sender] + amount <= MAX_PER_WALLET, "exceed max supply of per wallet amount");

        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%2;

        if(rand == 0){
            require(msg.value == amount * MINT_PRICE, "Mint: Incorrect payment");
            require(supplyPrestige + amount <= MAX_SUPPLY_PRESTIGE, "Mint: Max supply reached");
            _mint(msg.sender, TOKEN_ID_PRESTIGE, amount, "");
            supplyPrestige += amount;
            _owners[msg.sender] += amount;

        } else {
            require(msg.value == amount * MINT_PRICE, "Mint: Incorrect payment");
            require(supplyOrdinary + amount <= MAX_SUPPLY_ORDINARY, "Mint: Max supply reached");
            _mint(msg.sender, TOKEN_ID_ORDINARY, amount, "");
            supplyOrdinary += amount;
            _owners[msg.sender] += amount;
        }

        return rand;
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

