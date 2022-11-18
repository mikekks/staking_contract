// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract token is ERC1155 {
    uint256 public constant MAIN = 0;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct MushnSpore {
        uint256 tokenRate;
        bool staking;
        bool steal;
        string uri;
    }

    struct perAsset{
        mapping(uint=>MushnSpore) MushList;
        uint perTotalNFTs;
    }

    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmNSHyyoUm7qTGhodsV74ToFezxF5DJZ47KspRGsxNwa4f?filename=thridparty.json",
        "https://ipfs.io/ipfs/QmTifBGad4KVQ2zvE1AiUd2dTh4Y5dpJtBJBXwtnND6uXK?filename=init.json",
        "https://ipfs.io/ipfs/QmNZxdnaTrrR1UgepoQpXse6DHqBJYRcsFoC5s5XfsQWR2?filename=spore.json",
        "https://ipfs.io/ipfs/QmREGm7vkC5Fvr7JAGS5bD8mDt82LKWHib2KxZAkk7jzE9?filename=mushroom.json",
        "https://ipfs.io/ipfs/QmbHrs79ryps265HsELDnUbeGwTQeDP2aXFN4xQ62nJX2X?filename=stealer.josn",
        " "
    ];


    mapping(uint256 => string) public _uris;
    mapping(uint256 => uint256) public season;

    //mapping(uint256 => MushnSpore) public NFTinfo; // have to change private
    mapping(uint256 => bool) public stealer;

    mapping(address=>perAsset) public PerNFTsIdList;


    address owner;
    address public stakeContract;
    uint256 public currentSeason;
    uint256 totalSpore;
    uint256 totalMush;

    constructor()
        public
        ERC1155("https://ipfs.io/ipfs/QmYUZx4HsTd7R9LLbcn3X9q99fCpUfvQWhKuwoYYAaNHR4")
    {
        _mint(msg.sender, MAIN, 10e10, "");
        owner = msg.sender;
        currentSeason = 1;
        totalSpore = 0;
        totalMush = 0;
        _tokenIdCounter.increment();
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner || msg.sender == stakeContract,
            "Permission erR0!"
        );
        _;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return (_uris[tokenId]);
    }

    function setTokenUri(
        uint256 tokenId,
        uint256 opt
    ) public onlyOwner {
        _uris[tokenId] = IpfsUri[opt];
    }

    function setStakeContract(address _contract) public onlyOwner {
        stakeContract = _contract;
    }



    function mintMush(
        address _account,
        uint256 _tokenRate
    ) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _mint(_account, tokenId, 1, "");
        setTokenUri(tokenId, 1);
        //uint perTotalMush = PerNFTsIdList[_account].perTotalNFTs;
        PerNFTsIdList[_account].perTotalNFTs++;
        PerNFTsIdList[_account].MushList[tokenId].tokenRate = _tokenRate;
        PerNFTsIdList[_account].MushList[tokenId].staking = true;
        PerNFTsIdList[_account].MushList[tokenId].steal = false;
        PerNFTsIdList[_account].MushList[tokenId].uri = IpfsUri[1];

        season[tokenId] = currentSeason;
        totalMush++;
    }

    function _MushToSpore(
        uint256 _tokenId,
        uint256 _tokenRate,
        address _account
    ) public {
        require(PerNFTsIdList[_account].MushList[_tokenId].staking == true, "not Mushroom");

        PerNFTsIdList[_account].MushList[_tokenId].staking = false;
        PerNFTsIdList[_account].MushList[_tokenId].tokenRate = _tokenRate;
        setTokenUri(_tokenId, 2);
        PerNFTsIdList[_account].MushList[_tokenId].uri = IpfsUri[2];

        totalMush--;
        totalSpore++;
    }

    function _SporeToMush(
        uint256 _tokenId,
        uint256 _tokenRate,
        address _account
    ) public {
        require(PerNFTsIdList[_account].MushList[_tokenId].staking == false, "not Spore");

        PerNFTsIdList[_account].MushList[_tokenId].staking = true;
        PerNFTsIdList[_account].MushList[_tokenId].tokenRate = _tokenRate;
        setTokenUri(_tokenId, 3);
        PerNFTsIdList[_account].MushList[_tokenId].uri = IpfsUri[3];

        totalMush++;
        totalSpore--;
    }

    function mintStealer(address _account) public onlyOwner {
        require(balanceOf(_account, 0) > 10, "Not enough Main token"); // 10 is price
        _burn(_account, 0, 10);

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _mint(_account, tokenId, 1, "");
        setTokenUri(tokenId, 4);
        stealer[tokenId] = true; // true 의미, 혹시 몰라서 일단 정수로 설정

        //uint perTotalMush = PerNFTsIdList[_account].perTotalNFTs;
        PerNFTsIdList[_account].perTotalNFTs++;
        PerNFTsIdList[_account].MushList[tokenId].staking = false;
        PerNFTsIdList[_account].MushList[tokenId].steal = true;
        PerNFTsIdList[_account].MushList[tokenId].uri = IpfsUri[4];
    }

    function TotalNFTs() public view returns(uint256){
        return _tokenIdCounter.current();
    }


    function viewSeason(uint256 _tokenId) public view returns (uint256) {
        return season[_tokenId];
    }

    function updateSeason() public onlyOwner {
        currentSeason++;
    }

    function checkStealer(address _account, uint256 _stealtokenId) public view returns (bool) {
        return PerNFTsIdList[_account].MushList[_stealtokenId].steal;
    }

    function viewTokenRate(address _account, uint256 _tokenId) external view returns (uint256){
        return PerNFTsIdList[_account].MushList[_tokenId].tokenRate;
    }

    function isMush(address _account, uint256 _tokenId) external view returns (bool){
        return PerNFTsIdList[_account].MushList[_tokenId].staking;
    }

    function burn(
        address _account,
        uint256 _tokenId,
        uint256 _amount
    ) public {
        _burn(_account, _tokenId, _amount);
    }

}
