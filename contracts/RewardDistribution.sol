// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Reward Distribution Contract
 * @dev This contract allows for the distribution of ERC20 tokens as rewards.
 */
contract RewardDistribution is AccessControl {
    using SafeERC20 for IERC20;

    error InvalidArray();
    error InvalidAmount();
    error InvalidRecipient();

    /// Role for the reward sender.
    bytes32 public constant REWARD_SENDER_ROLE = keccak256("REWARD_SENDER_ROLE");

    /// The ERC20 token to be distributed.
    IERC20 public immutable token;

    /// Address of the reward treasury holding the tokens.
    address rewardTreasury;

    /**
     * @notice Emitted when a reward is successfully distributed.
     * @param recipient The address receiving the reward.
     * @param amount The amount of tokens rewarded.
     */
    event RewardDistributed(address indexed recipient, uint256 amount);

    constructor(address _rewardTreasury, address _token) {
        rewardTreasury = _rewardTreasury;
        token = IERC20(_token);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Updates the reward treasury address.
     * @param _rewardTreasury New address for the reward treasury.
     */
    function setRewardTreasury(address _rewardTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        rewardTreasury = _rewardTreasury;
    }

    /**
     * @dev Distributes rewards to multiple recipients.
     * @param recipients Array of addresses to receive rewards.
     * @param amounts Array of amounts to be distributed to each address.
     */
    function distributeRewards(
        address[] memory recipients,
        uint256[] memory amounts
    ) external onlyRole(REWARD_SENDER_ROLE) {
        if (recipients.length != amounts.length) revert InvalidArray();

        for (uint256 i = 0; i < recipients.length; i++) {
            _distributeReward(recipients[i], amounts[i]);
        }
    }

    /**
     * @dev Distributes reward to a single recipient.
     * @param recipient Address of the recipient.
     * @param amount Amount of the reward.
     */
    function distributeReward(address recipient, uint256 amount) public onlyRole(REWARD_SENDER_ROLE) {
        _distributeReward(recipient, amount);
    }

    /**
     * @dev Internal function handling the actual reward distribution logic.
     * @param recipient Address of the recipient.
     * @param amount Amount of the reward.
     */
    function _distributeReward(address recipient, uint256 amount) private {
        if (recipient == address(0)) revert InvalidRecipient();
        if (amount == 0) revert InvalidAmount();

        token.safeTransferFrom(rewardTreasury, recipient, amount);

        emit RewardDistributed(recipient, amount);
    }
}
