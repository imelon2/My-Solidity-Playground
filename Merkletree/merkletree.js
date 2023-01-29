const { Wallet } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const { randomBytes } = require("crypto");

const _address = "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2";

const addressList = new Array(15)
  .fill(0)
  .map(() => new Wallet(randomBytes(32).toString("hex")).address);
// console.log(addressList);


const merkleTree = new MerkleTree(
  addressList.concat(_address),
  keccak256,
  { hashLeaves: true, sortPairs: true }
);

const root = merkleTree.getHexRoot()
console.log(root);

const proof = merkleTree.getHexProof(keccak256(_address))
console.log(proof);
