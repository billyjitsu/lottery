// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title This is a mock contract to simulate a dAPI Proxy Contract.

contract MockQRNGProxy {

    mapping(address => mapping(address => bool)) public sponsorToRequesterToSponsorshipStatus;
    mapping(address => uint256) public requesterToRequestCountPlusOne;
    mapping(bytes32 => bytes32) private requestIdToFulfillmentParameters;

    function setSponsorshipStatus(address requester, bool sponsorshipStatus) external   
    {
        // Initialize the requester request count for consistent request gas
        // cost
        if (requesterToRequestCountPlusOne[requester] == 0) {
            requesterToRequestCountPlusOne[requester] = 1;
        }
        sponsorToRequesterToSponsorshipStatus[msg.sender][requester] = sponsorshipStatus;  
    }

    

}