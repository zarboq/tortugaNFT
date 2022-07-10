import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

pragma solidity ^0.8.0;

contract TortugaShip is ERC721Enumerable, Ownable {
    using SafeERC20 for IERC20;

    uint256 public constant MAX_SHIP = 250;
    bool public hasSaleStarted;
    bool public hasWhitelistSaleStarted;
    string public baseURI;

    mapping(address => bool) public whitelist;


    event Recovered(address token, uint256 amount);
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);
    event Mint(address to, uint256 id);
    event Whitelist(address userAddress);

    constructor() ERC721("Tortuga Ship", "SHIP") {
        hasSaleStarted = false;
        hasWhitelistSaleStarted = false;
    }

    function _baseURI() internal view override returns(string memory){
        return baseURI;
    }

    function  _mint() internal {
        uint256 mintIndex = totalSupply();
        _safeMint(msg.sender, mintIndex);
        emit Mint(msg.sender, mintIndex);
    }
    
    function mint(uint256 _numberToMint) public payable {
        uint256 supply = totalSupply();

        require(hasSaleStarted == true);
        require(_numberToMint <= 3, "You can mint maximum 3 ship");
        require(supply + _numberToMint < MAX_SHIP, "Exceeds MAX_SHIP");

        for (uint256 i = 0; i < _numberToMint; i++) {
            _mint();
        }
    }

    function mintWhitelist(uint256 _numberToMint) public payable {
        uint256 supply = totalSupply();

        require(hasWhitelistSaleStarted == true);
        require(whitelist[msg.sender] == true);
        require(_numberToMint <= 3, "You can mint maximum 3 ship");
        require(supply + _numberToMint < MAX_SHIP, "Exceeds MAX_SHIP");

        whitelist[msg.sender] = false;

        for (uint256 i = 0; i < _numberToMint; i++) {
            _mint();
        }
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function addWhitelist(address[] memory _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
            emit Whitelist(_addresses[i]);
        }
    }

    function startDrop() public onlyOwner {
        hasSaleStarted = true;
    }

    function pauseDrop() public onlyOwner {
        hasSaleStarted = false;
    }

    function startWhitelistDrop() public onlyOwner {
        hasWhitelistSaleStarted = true;
    }

    function pauseWhitelistDrop() public onlyOwner {
        hasWhitelistSaleStarted = false;
    }
    
    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAmount > 0, "Claim::recoverERC20: amount is 0");
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }
}