// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TaebaToken is ERC20, Ownable {
     using SafeMath for uint256;

  uint public duration = 600000;  // 10 Minutes in milliseconds
  uint public end;
  uint public nowTime = block.timestamp;
  uint256 private _totalSupply;
  address private tokensOwner;

    constructor() ERC20("TaebaToken", "TTK") {
        end = block.timestamp + duration;
        _totalSupply = 0;
        tokensOwner = msg.sender;
        _balances[tokensOwner]= _totalSupply; }

uint256 public transferTokens;
uint256 public lockedTokens;

mapping(address => uint) lockedTokensRecord;
mapping(address => uint) _balances;

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

// This function locks 30% of the tokens being mined
    function mint(address to, uint256 amount) public {
            lockedTokens  = (amount/100)* 30; 
            transferTokens = amount - lockedTokens;

            lockedTokensRecord[to] += lockedTokens ;  
            _mint(to, transferTokens);
            _balances[to] += transferTokens ;

            _mint(msg.sender, lockedTokens);
            _balances[msg.sender] += lockedTokens ;
    }

// This function release the locked assets when the timelock ends 
function withdraw(address to) public {
         require(lockedTokensRecord[to] > 0, "You do not have any outstanding Tokens");
         require(block.timestamp > end, "Timelock is not ended yet");
            _transfer(msg.sender, to,  lockedTokens); 

            lockedTokensRecord[to]= lockedTokens-- ;
            _balances[msg.sender] = balanceOf(msg.sender)-lockedTokensRecord[to] ; 
            _balances[to] += lockedTokensRecord[to] ;

 }
}
