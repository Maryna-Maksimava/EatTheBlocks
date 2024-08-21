pragma solidity 0.8.26;

import "./RewardSystem.sol";

contract TieredRewardSystem is RewardSystem{
    enum Tier{
        NONE,
        BRONZE,
        SILVER,
        GOLD }

        mapping(address => Tier) public userTiers;
        uint256 public constant BRONZE_MULTIPLIER = 1; 
        uint256 public constant SILVER_MULTIPLIER = 2; 
        uint256 public constant GOLD_MULTIPLIER = 3; 

        event TierAssigned(address indexed user, Tier tier);

        function assignTier (address user, Tier tier) external {
            userTiers[user] = tier;
            emit TierAssigned(user, tier);
        }

        function earnPoints(address user, uint256 points) public override {
            Tier tier = userTiers[user];
            uint256 multiplier = _tierMultiplier(tier);
            super.earnPoints(user, points * multiplier);
        }

        function _tierMultiplier ( Tier tier) internal pure returns(uint256){
            if (tier == Tier.BRONZE){
                return BRONZE_MULTIPLIER; }
            if (tier == Tier.SILVER){
                return SILVER_MULTIPLIER;}
            if (tier == Tier.GOLD){
                return GOLD_MULTIPLIER;
                 }
                 return 0;
        }


}