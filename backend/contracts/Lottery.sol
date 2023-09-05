// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is RrpRequesterV0, Ownable {
    // Events
    event RequestedRandomNumber(bytes32 indexed requestId);
    event ReceivedRandomNumber(bytes32 indexed requestId, uint256 randomNumber);

    // Global Variables
    uint256 public pot;
    uint256 public ticketPrice;
    uint256 public currentLotto = 1; // current currentLotto counter
    uint256 public endTime; // datetime that current currentLotto ends and lottery is closable
    uint256 public max_number; // highest possible number
    uint256 public fee = 0.01 ether;
    uint256 public max_duration = 604800; // 1 week in seconds

    address public airnode;
    address public sponsorWallet;
    bytes32 public endpointId;

    bool public lotteryStarted;
    
    // Errors
    error EndTimeReached(uint256 lotteryEndTime);
    error OutOfRange(uint256 guess);
    error NotEnoughEther();
    error LotteryNotStarted();
    error LotteryNotEnded();
    error NeedToTopUpSponsorWallet();
    error RequestDoesNotExist(bytes32 requestId);
    error PastTheMaxDuration(uint256 duration);

    // Mappings
    mapping(uint256 => mapping(uint256 => address[])) public tickets; // mapping of currentLotto => entry number choice => list of addresses that bought that entry number
    mapping(uint256 => uint256) public winningNumber; // mapping to store each currentLottos winning number
    mapping(bytes32 => bool) public pendingRequestIds; // mapping to store pending request ids

    /// @notice Initialize the contract with a set day and time of the currentLotto winners can be chosen
    constructor(address _airnodeRrpAddress) RrpRequesterV0(_airnodeRrpAddress){}

    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256,
        address _sponsorWallet
    ) external onlyOwner{
        airnode = _airnode;
        endpointId = _endpointIdUint256;
        sponsorWallet = _sponsorWallet;
    }

    // function startLottery(uint256 _ticketPrice, uint256 _max_number, uint256 _durationInSeconds) external onlyOwner{
    //     lotteryStarted = true;
    //     ticketPrice = _ticketPrice;
    //     max_number = _max_number;
    //     endTime = block.timestamp + _durationInSeconds;   
    // }

    /// @notice Start a new lottery
    /// @param _ticketPrice The price of a ticket in wei
    /// @param _max_number The highest possible number that can be chosen
    /// @param _durationInSeconds The duration of the lottery in seconds
    /// Requiring a small payment to stop spamming of lotteries
    function startLottery(uint256 _ticketPrice, uint256 _max_number, uint256 _durationInSeconds) payable external {
        if (msg.value < fee ) revert NotEnoughEther();
        if (_durationInSeconds > max_duration) revert PastTheMaxDuration(_durationInSeconds);
        lotteryStarted = true;
        ticketPrice = _ticketPrice;
        max_number = _max_number;
        endTime = block.timestamp + _durationInSeconds;   
    }


    /// @notice Buy a ticket for the current currentLotto
    /// @param _number The participant's chosen lottery number for which they're buying a ticket
    function enter(uint256 _number) external payable {
        if (lotteryStarted == false) revert LotteryNotStarted();
        if (_number > max_number) revert OutOfRange(_number); // guess has to be between 1 and max_number
        if (block.timestamp >= endTime) revert EndTimeReached(endTime); // lottery has to be open
        if (msg.value < ticketPrice) revert NotEnoughEther(); // Not enough ether sent
        tickets[currentLotto][_number].push(msg.sender); // add user's address to list of entries for their number under the current currentLotto
        pot += msg.value; // account for the ticket sale in the pot
    }

    /// @notice Request winning random number from Airnode
    function getWinningNumber() external payable {
        if (lotteryStarted != true) revert LotteryNotStarted();
        if(block.timestamp < endTime) revert LotteryNotEnded();
        if(msg.value < 0.01 ether) revert NeedToTopUpSponsorWallet();
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointId,
            address(this),
            sponsorWallet,
            address(this),
            this.closeCurrentLotto.selector,
            ""
        );
        pendingRequestIds[requestId] = true;
        emit RequestedRandomNumber(requestId);
         (bool success, ) = sponsorWallet.call{value: msg.value}(""); // Send funds to sponsor wallet
         require(success, "Transfer failed.");   
    }

    /// @notice Close the current currentLotto and calculate the winners. Can be called by anyone after the end time has passed.
    /// @param requestId the request id of the response from Airnode
    /// @param data payload returned by Airnode
    function closeCurrentLotto(
        bytes32 requestId,
        bytes calldata data // Airnode returns the requestId and the payload to be decoded later
    )
        external
        onlyAirnodeRrp
    {
        if(pendingRequestIds[requestId] == false) revert RequestDoesNotExist(requestId); // Check if the request is pending (i.e. the request was made by this contract
        delete pendingRequestIds[requestId]; // If the request has been responded to, remove it from the pendingRequestIds mapping

        uint256 _randomNumber = abi.decode(data, (uint256)) % max_number; // Decode the random number from the data and modulo it by the max number
        emit ReceivedRandomNumber(requestId, _randomNumber); // Emit an event that the random number has been received

        if(block.timestamp < endTime) revert LotteryNotEnded();
        

        // The rest we can leave unchanged
        winningNumber[currentLotto] = _randomNumber;
        address[] memory winners = tickets[currentLotto][_randomNumber];
        currentLotto++;
        lotteryStarted = false;
        if (winners.length > 0) {
            uint256 earnings = pot / winners.length;
            pot = 0;
            for (uint256 i = 0; i < winners.length; i++) {
                (bool success, ) = payable(winners[i]).call{value: earnings}(""); // send earnings to each winner
                require(success, "Transfer failed.");   
            }
        }
    }

    /// @notice Read only function to get addresses entered into a specific number for a specific currentLotto
    /// @param _currentLotto The currentLotto to get the list of addresses for
    /// @param _number The number to get the list of addresses for
    function getEntriesForNumber(uint256 _number, uint256 _currentLotto)
        public
        view
        returns (address[] memory)
    {
        return tickets[_currentLotto][_number];
    }

    //Only Owner functions

    /// @notice Set the minimum fee required to start a new lottery
    function setMinimumFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    /// @notice Set the maximum duration of a lottery
    function setMaxDuration(uint256 _durationInSeconds) external onlyOwner {
        max_duration = _durationInSeconds;
    }

    // testing only to be removed
    function withdraw() external onlyOwner {
        pot = 0;
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    /// @notice Handles when funds are sent directly to the contract address
    receive() external payable {
        pot += msg.value; // add funds to the pot
    }
}
