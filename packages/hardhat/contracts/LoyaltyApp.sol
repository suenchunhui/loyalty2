// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LoyaltyApp is ERC721, Ownable {
    // Variables
    uint256 private currentTokenId;
    IERC20 private rewardToken;
    bool private isTokenTransferable;

    // Events
    event TokenMinted(address indexed recipient, uint256 indexed tokenId);
    event TokenBurned(uint256 indexed tokenId);
    event RewardTokenSet(address indexed rewardToken, bool indexed isTransferable);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        currentTokenId = 1;
    }

    // Function to mint a token and give it to the recipient
    function mintToken(address recipient) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");

        // Mint new token
        _safeMint(recipient, currentTokenId);

        emit TokenMinted(recipient, currentTokenId);

        // Increment current token id
        currentTokenId++;
    }

    // Function to burn a token
    function burnToken(uint256 tokenId) external {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not the owner nor approved");

        // Burn token
        _burn(tokenId);

        emit TokenBurned(tokenId);
    }

    // Function to set the reward token and its transferability
    function setRewardToken(address token, bool transferable) external onlyOwner {
        require(token != address(0), "Invalid token address");
        
        rewardToken = IERC20(token);
        isTokenTransferable = transferable;

        emit RewardTokenSet(token, transferable);
    }

    // Function to redeem a reward by burning the token
    function redeemReward(uint256 tokenId) external {
        require(ownerOf(tokenId) == _msgSender(), "Caller is not the token owner");
        require(address(rewardToken) != address(0), "Reward token is not set");

        // Burn token
        _burn(tokenId);

        // Transfer reward token to caller
        rewardToken.transfer(_msgSender(), 1);
    }
}