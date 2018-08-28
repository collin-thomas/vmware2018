
pragma solidity ^0.4.18;

/* This is horrible code. */

contract vSwag {
    address public vendorName;
    uint public swagGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    //token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool swagGoalReached = false;
    bool vSwagClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event SwagswagToken(address backer, uint amount, bool isContribution);

	 /* This creates an array with all balances */
   // mapping (address => uint256) public balanceOf;
	
    /**
     * Constructor function
     *
     * Setup the owner
     */
    function vSwagConstructor(
        address ifSuccessfulSendTo,
        uint swagGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        vendorName = ifSuccessfulSendTo;
        swagGoal = swagGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
		balanceOf[msg.sender] = 1000;              // How much swag coin you got, captain?

    }

	/* Send swag */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);           // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        balanceOf[msg.sender] -= _value;                    // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        return true;
    }
	
    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        transfer(msg.sender, amount / price);
       emit SwagswagToken(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= swagGoal){
            swagGoalReached = true;
            emit GoalReached(vendorName, amountRaised);
        }
    }


    /**
     * Decrement Swag
     *
     */
    function safeWithdrawal() public afterDeadline {
        if (!swagGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                   emit SwagswagToken(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (swagGoalReached && vendorName == msg.sender) {
            if (vendorName.send(amountRaised)) {
               emit SwagswagToken(vendorName, amountRaised, false);
			} else {
				//something something...give back swag coin
                swagGoalReached = false;
            }
		
        }
    }
}