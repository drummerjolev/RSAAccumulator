pragma solidity >=0.4.25 <0.6.0;

import {RSAAccumulator} from "./RSAAccumulator.sol";

contract PlasmaCashMockup {

    uint64 constant public numberOfCoins = uint64(1) << 32;
    RSAAccumulator public rsaAccumulator;

    uint256 constant public NlengthIn32ByteLimbs = 8; // 1024 bits for factors, 2048 for modulus
    uint256 constant public NlengthInBytes = 32 * NlengthIn32ByteLimbs;
    uint256 constant public NLength = NlengthIn32ByteLimbs * 8 * 32;
    uint256 constant public g = 3;
    uint64 public lastBlock = 0;

    mapping(uint64 => uint256[NlengthIn32ByteLimbs]) blockAccumulators; // try to store as static array for now; In BE

    constructor(address _accumulator)
    public
    {
        blockAccumulators[0][NlengthIn32ByteLimbs - 1] = g;
        rsaAccumulator = RSAAccumulator(_accumulator);
    }

    function getAccumulatorForBlock(uint64 blockNumber)
    public
    view
    returns (uint256[NlengthIn32ByteLimbs] memory accum) {
        accum = blockAccumulators[blockNumber];
    }

    function updateAccumulator(
        uint256[] memory _limbs)
    public {
        blockAccumulators[lastBlock + 1] = rsaAccumulator.updateAccumulatorMultiple(blockAccumulators[lastBlock], _limbs);
        lastBlock++;
    }


    function checkInclusionProof(
        uint64 prime,
        uint256[] memory witnessLimbs,
        uint256[NlengthIn32ByteLimbs] memory initialAccumulator,
        uint256[NlengthIn32ByteLimbs] memory finalAccumulator
    )
    public
    view
    returns (bool isValue) {
        return rsaAccumulator.checkInclusionProof(prime, witnessLimbs, initialAccumulator, finalAccumulator);
    }

    function checkNonInclusionProof(
        uint64[] memory primes,
        uint256[] memory rLimbs,
        uint256[] memory cofactorLimbs,
        uint256[NlengthIn32ByteLimbs] memory initialAccumulator,
        uint256[NlengthIn32ByteLimbs] memory finalAccumulator
    )
    public
    view
    returns (bool isValue) {
        return rsaAccumulator.checkNonInclusionProof(primes, rLimbs, cofactorLimbs, initialAccumulator, finalAccumulator);
    }

}
