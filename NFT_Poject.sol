// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NFTToken is ERC721, ERC721URIStorage, Pausable, Ownable {
    string BaseURI;
    uint256 private  whiteListedUserLimit;
    uint256 public publicMintLimit;
    uint256 private adminLimit;
    uint256 public countForWhiteListers;
    uint256 public countForPublic;
    uint256 public countAdmin;
    uint256 public MAXMintPerPerson;
    bool public isPublicSaleActive;
    uint256 private startTime;
    uint256 private endTime;
    uint256 private  difference;
    

    struct NftInfo{
        uint256 ID;
       string hash;
       string Name;
    }
    
    mapping(uint=> NftInfo) public NftData;

    mapping(address => uint256) private personMintCounts;
    mapping(address => bool) private whiteListers;
    mapping(address => bool) private whiteListerAdmins;
    mapping(address => bool) private admins;


    constructor(uint WhiteListLimit, uint PublicMintLimit, uint AdminlMintLimit, uint perPersonLimit) ERC721("Alpha Girls Clubs", "AL") {
  BaseURI= " https://gateway.pinata.cloud/ipfs/";
          whiteListedUserLimit = WhiteListLimit;
        publicMintLimit = PublicMintLimit;
        adminLimit = AdminlMintLimit;
        startTime = block.timestamp;
        endTime = startTime + 10 minutes;
        isPublicSaleActive = false;
        MAXMintPerPerson = perPersonLimit;
        
    }
  

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    function safeMint(address to, uint256 tokenId)
        public
    {
        _safeMint(to, tokenId);
        //_setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(BaseURI, NftData[tokenId].hash));
    }
   
    
  
    function showRemaingTimePeriod() public view returns(uint){
        return endTime - block.timestamp;
    }
  
    

    function setWhiteListers(address user, bool whiteListStatus) public onlyOwner whenNotPaused{
        require(!whiteListers[user], "Already whitelisted");
        whiteListers[user] = whiteListStatus;
    }

    modifier isPersonIllegible(address user){
        require(personMintCounts[user] < MAXMintPerPerson, "Max persons limit overflow");
       
        personMintCounts[user] += 1;
        _;
    }

    function WhiteListerMintNFTDetails(
        uint256 _NFTID, 
        string memory _NFTName, 
        string memory _hash) public isPersonIllegible(msg.sender) whenNotPaused {
        require(whiteListers[msg.sender] , "you are not a white lister");
        require(countForWhiteListers < whiteListedUserLimit, "you cannot mint more than WhiteList Mintlimit");
        require(block.timestamp < endTime, "Time up");
        if(block.timestamp > endTime){
            difference = whiteListedUserLimit-countForWhiteListers;

            publicMintLimit = publicMintLimit + (whiteListedUserLimit-countForWhiteListers);
         

            setDifference(difference);
           
        }
        require(block.timestamp < endTime, "Time up");
        
        mintwithDetail(_NFTID, _NFTName, _hash);
        countForWhiteListers++;
    }
    function setDifference(uint value) private{
        difference = value;
    }
    function showPublicMintingLimit() public view returns(uint) {
        return publicMintLimit;
    }

    function PublicMintNFTDetails(
        uint256 _NFTID, 
        string memory _NFTName, 
        string memory _hash) public isPersonIllegible(msg.sender) whenNotPaused {
        require(isPublicSaleActive,"Public sale is not active");
        if(block.timestamp > endTime ){
        publicMintLimit = publicMintLimit + (whiteListedUserLimit-countForWhiteListers);
        }
        require(countForPublic <= publicMintLimit,"you cannot mint more than Public Mintlimit");
        mintwithDetail(_NFTID, _NFTName, _hash);
        countForPublic++;
    }

    function AdminMintNFTDetails(
        uint256 _NFTID, 
        string memory _NFTName, 
        string memory _hash) public isPersonIllegible(msg.sender) whenNotPaused {
        require(admins[msg.sender], "You are not authorized");
        require(countAdmin <= adminLimit, "");
        mintwithDetail(_NFTID, _NFTName, _hash);
        countAdmin++;
    }

    function mintwithDetail(uint tokenId, string memory _Name, string memory _hash) private {
        safeMint(msg.sender, tokenId);
      
        NftData[tokenId].ID=tokenId;
        NftData[tokenId].hash=_hash;
        NftData[tokenId].Name=_Name;
    } 
    
    function setPersonPerMint(uint value) public onlyOwner whenNotPaused{
        MAXMintPerPerson = value;
    }
    function setPublicSaleActive(bool status) public onlyOwner whenNotPaused {
        isPublicSaleActive = status;
    }
    function setAdmins(address user, bool _status) public onlyOwner whenNotPaused {
        admins[user] = _status;
    }
    function setWhiteListerAdmin(address user) public onlyOwner whenNotPaused {
        whiteListerAdmins[user] = true;
    }
    function showNFTRecord(uint NFTId) public view returns(NftInfo memory){
        return NftData[NFTId];
    }
    function setTimePeriod(uint noOfMinuts) public onlyOwner whenNotPaused {
        endTime = startTime + noOfMinuts;        
    }


}
