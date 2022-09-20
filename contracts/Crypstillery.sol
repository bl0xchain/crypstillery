// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Recoverability.sol";

contract Crypstillery is ERC721URIStorage, Ownable, Recoverability {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public cost = 0.05 ether;
    uint256 public maxSupply = 20;
    bool public revealed = false;
    string public notRevealedUri;
    mapping(address => bool) public whitelisted;

    event TokenMinted(uint tokenId, address to);
    event TokenBurned(uint tokenId, address from);
    event TokenRecovered(uint tokenId, address from);
    event Withdrawn(address owner, uint amount);

    constructor(string memory _initNotRevealedUri) ERC721("Crypstillery", "CPTL") Recoverability(msg.sender) {
        notRevealedUri = _initNotRevealedUri;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function mint(address to, string memory tokenURI_) public payable {
        uint256 supply = totalSupply();
        require(supply + 1 <= maxSupply);

        if (msg.sender != owner()) {
            if(whitelisted[msg.sender] != true) {
                require(msg.value == cost);
            }
        }
        _safeMint(to, _tokenIds.current());
        _setTokenURI(_tokenIds.current(), tokenURI_);
        _tokenIds.increment();

        emit TokenMinted(_tokenIds.current(), msg.sender);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        
        if(revealed == false) {
            return notRevealedUri;
        }
        return super.tokenURI(tokenId);
    }

    function reveal() public onlyOwner() {
        revealed = true;
    }
  
    function setCost(uint256 _newCost) public onlyOwner() {
        cost = _newCost;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function whitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }
 
    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function _burn(uint256 tokenId) internal override(ERC721URIStorage) {
        safeTransferFrom(msg.sender, burnAddress, tokenId);
    }

    function setBurnAddress(address newBurnAddress) public onlyOwner {
        _setBurnAddress(newBurnAddress);
    }

    function recoverToken(address from, uint256 tokenId) public onlyOwner {
        require(_exists(tokenId), "ERC721: token does not exist");
        _transfer(from, recoveryAddress, tokenId);
        emit TokenRecovered(tokenId, from);
    }

    function setRecoveryAddress(address newRecoveryAddress) public onlyOwner {
        require(address(newRecoveryAddress) != address(0), "Recovery address cannot be coinbase");
        _setRecoveryAddress(newRecoveryAddress);
    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "caller is not owner nor approved");
        _burn(tokenId);
        emit TokenBurned(tokenId, msg.sender);
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
        emit Withdrawn(msg.sender, address(this).balance);
    }
}