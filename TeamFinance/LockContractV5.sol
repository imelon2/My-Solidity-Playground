// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface GeneratedInterface {
  function NFT (  ) external view returns ( address );
  function addTokenToFreeList ( address token ) external;
  function allDepositIds ( uint256 ) external view returns ( uint256 );
  function companyWallet (  ) external view returns ( address );
  function depositId (  ) external view returns ( uint256 );
  function depositsByWithdrawalAddress ( address, uint256 ) external view returns ( uint256 );
  function extendLockDuration ( uint256 _id, uint256 _unlockTime ) external;
  function feesInUSD (  ) external view returns ( uint256 );
  function getAllDepositIds (  ) external view returns ( uint256[] memory);
  function getDepositDetails ( uint256 _id ) external view returns ( address _tokenAddress, address _withdrawalAddress, uint256 _tokenAmount, uint256 _unlockTime, bool _withdrawn, uint256 _tokenId, bool _isNFT, uint256 _migratedLockDepositId, bool _isNFTMinted );
  function getDepositsByWithdrawalAddress ( address _withdrawalAddress ) external view returns ( uint256[] memory);
  function getFeesInETH ( address _tokenAddress ) external view returns ( uint256 );
  function getTotalTokenBalance ( address _tokenAddress ) external view returns ( uint256 );
  function initialize (  ) external;
  function isFreeToken ( address token ) external view returns ( bool );
  function listMigratedDepositIds ( uint256 ) external view returns ( uint256 );
  function lockNFTs ( address _tokenAddress, address _withdrawalAddress, uint256 _amount, uint256 _unlockTime, uint256 _tokenId, bool _mintNFT ) external returns ( uint256 _id );
  function lockTokens ( address _tokenAddress, address _withdrawalAddress, uint256 _amount, uint256 _unlockTime, bool _mintNFT ) external returns ( uint256 _id );
  function lockedNFTs ( uint256 ) external view returns ( address tokenAddress, address withdrawalAddress, uint256 tokenAmount, uint256 unlockTime, bool withdrawn, uint256 tokenId );
  function lockedToken ( uint256 ) external view returns ( address tokenAddress, address withdrawalAddress, uint256 tokenAmount, uint256 unlockTime, bool withdrawn );
//   function migrate ( uint256 _id, tuple params, bool noLiquidity, uint160 sqrtPriceX96, bool _mintNFT ) external;
  function mintNFTforLock ( uint256 _id ) external;
  function nftMinted ( uint256 ) external view returns ( bool );
  function nonfungiblePositionManager (  ) external view returns ( address );
  function onERC721Received ( address, address, uint256, bytes memory) external returns ( bytes4 );
  function owner (  ) external view returns ( address );
  function pause (  ) external;
  function paused (  ) external view returns ( bool );
  function priceEstimator (  ) external view returns ( address );
  function removeTokenFromFreeList ( address token ) external;
  function renounceOwnership (  ) external;
  function setCompanyWallet ( address _companyWallet ) external;
  function setFeeParams ( address _priceEstimator, address _usdTokenAddress, uint256 _feesInUSD, address _companyWallet ) external;
  function setFeesInUSD ( uint256 _feesInUSD ) external;
  function setNFTContract ( address _nftContractAddress ) external;
  function setNonFungiblePositionManager ( address _nonfungiblePositionManager ) external;
  function setNotEntered (  ) external;
  function setV3Migrator ( address _v3Migrator ) external;
  function splitLock ( uint256 _id, uint256 _splitAmount, uint256 _splitUnlockTime, bool _mintNFT ) external returns ( uint256 _splitLockId );
  function transferLocks ( uint256 _id, address _receiverAddress ) external;
  function transferOwnership ( address newOwner ) external;
  function transferOwnershipNFTContract ( address _newOwner ) external;
  function unpause (  ) external;
  function usdTokenAddress (  ) external view returns ( address );
  function v3Migrator (  ) external view returns ( address );
  function walletTokenBalance ( address, address ) external view returns ( uint256 );
  function withdrawTokens ( uint256 _id, uint256 _amount ) external;
}
