pragma solidity 0.8.26;

abstract contract RewardSystem{
    mapping(address => uint256) public rewardBalances;

    event pointsEarned(address indexed user, uint256 points);
    event PointsRedeemed(address indexed user, uint256 points);
    event PointsTransfered(address indexed user, address indexed to, uint256 points);

    error InsufficientPoints(address user, uint256 requested, uint256 available);
    error InvalidPointsAmount(uint256 points);

    function earnPoints(address user, uint256 points) public virtual {
        if (points == 0){
            revert InvalidPointsAmount(points);
        }
        rewardBalances[user] += points;
        emit pointsEarned(user, points);
    }

    function redeemPoints(uint256 points) public virtual {
        if (rewardBalances[msg.sender] < 0){
            revert InsufficientPoints(msg.sender, points, rewardBalances[msg.sender]);
        }
        rewardBalances[msg.sender] -= points;
        emit PointsRedeemed(msg.sender, points);
    }

    function transferPoints(address to, uint256 points) public virtual {
        if (rewardBalances[msg.sender] < 0){
            revert InsufficientPoints(msg.sender, points, rewardBalances[msg.sender]);
        }
        rewardBalances[msg.sender] -= points;
        rewardBalances[to] += points;
        emit PointsTransfered(msg.sender, to, points);
    }
    function getBalance(address user) public view virtual returns (uint256) {
        return rewardBalances[user];
    }

}    
