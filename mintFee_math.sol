////// UNISWAPV2 ///////

    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1)); // 100100000000000000000000 * 100100000000000000000000 = 10020010000000000000000000000000000000000000000 = 100100000000000000000000
                uint rootKLast = Math.sqrt(_kLast); // 100000000000000000000000 * 100000000000000000000000 = 10000000000000000000000000000000000000000000000 = 100000000000000000000000
                if (rootK > rootKLast) { // 100100000000000000000000 - 100000000000000000000000 -> pair accumulated 100 LP token 
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast)); // 100000000000000000000000 * (100000000000000000000) = 10000000000000000000000000000000000000000000
                    uint denominator = rootK.mul(5).add(rootKLast); // 100100000000000000000000*5 + 100000000000000000000000 = 600500000000000000000000
                    uint liquidity = numerator / denominator; // 10000000000000000000000000000000000000000000/600500000000000000000000 = 16652789342214820982
                    if (liquidity > 0) _mint(feeTo, liquidity); // 16652789342214820982
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }


/////// 16652789342214820982 LP Tokens are being minted to feeTo, which is 1/6th of the total accumulated amount (100100000000000000000000 - 100000000000000000000000)





//////// EXCALIBURV2 /////////

  function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {//@audit ensure no accumulation during stableSwap
    if(stableSwap) return false; //note: early return: no mintFee for stableSwap

    (uint ownerFeeShare, address feeTo) = IExcaliburV2Factory(factory).feeInfo();//OK, get fees
    feeOn = feeTo != address(0);//OK, zero check
    uint _kLast = kLast;//OK
    // gas savings
    if (feeOn) {//note: mechanism which only works if its updated after all recent liquidity events
      if (_kLast != 0) {//OK
        uint rootK = Math.sqrt(_k(uint(_reserve0), uint(_reserve1)));// 100100000000000000000000 * 100100000000000000000000 = 10020010000000000000000000000000000000000000000 = 100100000000000000000000
        uint rootKLast = Math.sqrt(_kLast);// 100000000000000000000000*100000000000000000000000 = 10000000000000000000000000000000000000000000000 = 100000000000000000000000
        if (rootK > rootKLast) { // 100100000000000000000000 - 100000000000000000000000
          uint d = (FEE_DENOMINATOR / ownerFeeShare).sub(1); // (100000 / 50000) - 1 = 1 
          uint numerator = totalSupply.mul(rootK.sub(rootKLast)); // 100000000000000000000000 * (100100000000000000000000-100000000000000000000000) = 10000000000000000000000000000000000000000000
          uint denominator = rootK.mul(d).add(rootKLast); // 100100000000000000000000 + 100000000000000000000000 = 200100000000000000000000
          uint liquidity = numerator / denominator; // 10000000000000000000000000000000000000000000 / 200100000000000000000000 = 49975012493753123438
          if (liquidity > 0) _mint(feeTo, liquidity); // 49975012493753123438
        }
      }
    } else if (_kLast != 0) {
      kLast = 0;
    }
  }

//////// 49975012493753123438 LP tokens are being minted to feeTo, out of 100000000000000000000 accumulated -> 50% /////////
