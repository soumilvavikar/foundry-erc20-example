// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface tokenRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _extraData
    ) external;
}

contract ManualToken {
    // Public variables of the token
    string public name;
    string public symbol;
    /* 18 decimals is the strongly suggested default, avoid changing it */
    uint8 public decimals = 18;

    uint256 public totalSupply;

    // Mapings for storing balances and allowances
    mapping(address => uint256) s_balances;
    mapping(address => mapping(address => uint256)) public allowance;

    /**
     * Events - to notify clients of the blockchain on the events that are performed by the contract
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        // Update total supply with the decimal amount
        totalSupply = initialSupply * 10 ** uint256(decimals); 
        // Give the creator all initial tokens
        s_balances[msg.sender] = totalSupply; 

        // Set the name for display purposes
        name = tokenName; 
        // Set the symbol for display purposes
        symbol = tokenSymbol; 
    }

    /**
     * Defining: "name", decimal, and totalSupply
     *  - Approach 1: Define a function named "name", decimal, and totalSupply (see commented lines below)
     *  - Approach 2: Define a public variable - hardcode it
     *  - Approach 3: Define a public variable and initialize it in the contstructor. (used this approach in this example)
     */
    /*
    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    // OR

    string public name = "Manual Token";

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether; // 1000000000000000000
    }
    */

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool success) {
        // Step 1: Run necessary checks
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0));
        // Check if the sender has enough
        require(s_balances[_from] >= _value);
        // Check for overflows
        require(s_balances[_to] + _value >= s_balances[_to]);

        // Save this for an assertion in the future
        uint256 previousBalances = s_balances[_from] + s_balances[_to];

        // Step 2: If all conditions are met, complete the transfer
        // Subtract from the sender
        s_balances[_from] -= _value;
        // Add the same to the recipient
        s_balances[_to] += _value;

        // Step 3: Emit the transfer event.
        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(s_balances[_from] + s_balances[_to] == previousBalances);

        // Step 4: Return success = true if the function executed successfully.
        return true;
    }

    /**
     * This function returns the balanceOf the address sent in the function call
     * @param _owner - address of the account owner we need balance of
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return s_balances[_owner];
    }

    /**
     * This function will transfer tokens from caller's account to the account at _to address
     * @param _to transfer to account
     * @param _value amount of tokens to be transferred
     */
    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        /*
         * After implementing the _transfer internal function in depth, we don't need to do that manually again here.
         * We can directly call the _transfer method, like below.
         */

        return _transfer(msg.sender, _to, _value);

        /*
         * The following code was the initial / first pass code for the transfer method.
         * However, we need to perform the _transfer operation multiple times within various functions
         * AND also to avoid it being overriden, we moved that logic to a internal function
         */

        /*
        uint256 recieverPreviousBalance = balanceOf(_to);
        uint256 senderPreviousBalance = balanceOf(msg.sender);

        s_balances[_to] += _value;
        s_balances[msg.sender] -= _value;

        uint256 recieverFinalBalance = balanceOf(_to);
        uint256 senderFinalBalance = balanceOf(msg.sender);

        require(recieverPreviousBalance + _value == recieverFinalBalance);
        require(senderPreviousBalance - _value == senderFinalBalance);

        return true;
        */
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from` (leverage the concept of allowance)
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // Step 1: Check Allowance
        require(_value <= allowance[_from][msg.sender]);
        // Step 2: Reduce the allowance amount
        allowance[_from][msg.sender] -= _value;
        // Step 3: Make the transfer
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        // Step 1: Set the allowance
        allowance[msg.sender][_spender] = _value;
        // Step 2: Emit approval event for clients on the blockchain
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(
                msg.sender,
                _value,
                address(this),
                _extraData
            );
            return true;
        }
    }

    /**
     * Destroy / Burn tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        // Step 1: Check if the message sender has enough
        require(s_balances[msg.sender] >= _value);
        // Step 2: Reduce the token balance from the message sender
        s_balances[msg.sender] -= _value;
        // Step 3: Reduce the number of tokens from the total supply of the tokens
        totalSupply -= _value;
        // Step 4: Emit the event to notify clients on the blockchain
        emit Burn(msg.sender, _value);

        return true;
    }

    /**
     * Destroy tokens from other account (leverages the concept of allowance)
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(
        address _from,
        uint256 _value
    ) public returns (bool success) {
        // Step 1: Do necessary validations
        // Check if the targeted balance is enough
        require(s_balances[_from] >= _value);
        // Check allowance limit and the _value in the function request is less than equal to that limit
        require(_value <= allowance[_from][msg.sender]);
        
        // Step 2: Reduce the token balance from the target address
        s_balances[_from] -= _value;
        // Step 3: Reduce the allowance for the message sender towards the target account
        allowance[_from][msg.sender] -= _value;
        // Step 4: Reduce the number of tokens from the total supply of the tokens
        totalSupply -= _value;
        // Step 5: Emit the event to notify clients on the blockchain
        emit Burn(_from, _value);

        return true;
    }
}
