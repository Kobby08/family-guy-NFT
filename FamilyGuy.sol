// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FamilyGuy is ERC721, Ownable {
    using Strings for uint256;

    uint256 public maxSupply = 4;
    uint256 public maxMintPerWallet = 2;
    uint256 public totalSupply;
    bool public isPreMint;
    bool public isPublicMint;
    bool public isRevealed;
    string public baseURI;
    string public previewURI;
    mapping(address => bool) public whiteListedWallets;
    mapping(address => uint256) mintedWallets;

    constructor(string memory _baseURI, string memory _previewURI)
        ERC721("Family Guy", "FAMGUY")
    {
        setBaseURI(_baseURI);
        setPreviewURI(_previewURI);
        whiteListedWallets[msg.sender] = true;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setPreviewURI(string memory _previewURI) public onlyOwner {
        previewURI = _previewURI;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        require(
            totalSupply <= _maxSupply,
            "max supply can not be less than the total supply"
        );
        maxSupply = _maxSupply;
    }

    function setMaxMintPerWallet(uint256 _maxMint) external onlyOwner {
        require(_maxMint < maxSupply, "max mint can not exceed max supply");
        maxMintPerWallet = _maxMint;
    }

    function togglePreMint() external onlyOwner {
        isPreMint = !isPreMint;
    }

    function togglePublicMint() external onlyOwner {
        isPublicMint = !isPublicMint;
    }

    function toogleRevealed() external onlyOwner {
        isRevealed = true;
    }

    function addAddress(address _address) external onlyOwner {
        whiteListedWallets[_address] = true;
    }

    modifier soldOut() {
        require(totalSupply < maxSupply, "NFTs are sold out");
        _;
    }

    modifier mintExceeded() {
        require(
            mintedWallets[msg.sender] < maxMintPerWallet,
            "You have exceed your number of minting"
        );
        _;
    }

    // check total supply is less than max supply
    // address has reached max mint
    function preMint() external soldOut mintExceeded {
        require(isPreMint, "Pre miniting has not started");
        require(whiteListedWallets[msg.sender], "Address is not whitelisted");

        totalSupply++;
        uint256 newTokenId = totalSupply;
        mintedWallets[msg.sender]++;
        _safeMint(msg.sender, newTokenId);
    }

    function publicMint() external soldOut mintExceeded {
        require(isPublicMint, "Minting has not started");
        totalSupply++;
        uint256 newTokenId = totalSupply;
        mintedWallets[msg.sender]++;
        _safeMint(msg.sender, newTokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (isRevealed == false) {
            return previewURI;
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }
}
