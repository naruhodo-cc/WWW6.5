// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC-20 标准接口，用于与 USDC 合约交互
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title 增强版多币种打赏合约
 * @dev 支持 ETH（按法币汇率结算）和 USDC 直接支付
 */
contract TipJar {
    address public owner;
    uint256 public totalEthTipsReceived;
    
    // USDC 代币合约实例 (以太坊主网 USDC 地址: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eb48)
    IERC20 public usdcToken;

    // 状态变量
    mapping(string => uint256) public conversionRates; // 法币兑 ETH 汇率 (1法币 = X wei)
    mapping(address => uint256) public ethTipPerPerson; // 每个地址累计打赏的 ETH (wei)
    mapping(address => uint256) public usdcTipPerPerson; // 每个地址累计打赏的 USDC
    
    string[] public supportedCurrencies;
    mapping(string => uint256) public tipsPerCurrency; // 记录各币种累计打赏金额（名义金额）

    // 事件：用于前端监听交易结果
    event TippedInEth(address indexed tipper, uint256 amount, string currency);
    event TippedInUSDC(address indexed tipper, uint256 amount);

    constructor(address _usdcAddress) {
        owner = msg.sender;
        usdcToken = IERC20(_usdcAddress); // 初始化 USDC 合约地址

        // 预设默认汇率（根据文档：1 USD = 0.0005 ETH = 5 * 10^14 wei）
        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // --- 核心打赏功能 ---

    /**
     * @notice 直接以 ETH 打赏
     */
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        
        ethTipPerPerson[msg.sender] += msg.value;
        totalEthTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
        
        emit TippedInEth(msg.sender, msg.value, "ETH");
    }

    /**
     * @notice 按法币金额支付对应的 ETH
     * @param _currencyCode 币种代码如 "USD"
     * @param _amount 法币数量（支持整数，若需小数需前端放缩）
     */
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 requiredEth = convertToEth(_currencyCode, _amount);
        require(msg.value == requiredEth, "Sent ETH doesn't match the converted amount");

        ethTipPerPerson[msg.sender] += msg.value;
        totalEthTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;

        emit TippedInEth(msg.sender, msg.value, _currencyCode);
    }

    /**
     * @notice 直接使用 USDC 进行打赏
     * @dev 用户需先在 USDC 合约调用 approve() 授权此合约
     * @param _amount USDC 数量 (注意：USDC 是 6 位小数)
     */
    function tipInUSDC(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");

        // 从用户钱包转移 USDC 到合约
        bool success = usdcToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "USDC transfer failed");

        usdcTipPerPerson[msg.sender] += _amount;
        tipsPerCurrency["USDC"] += _amount;

        emit TippedInUSDC(msg.sender, _amount);
    }

    // --- 管理员功能 ---

    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");
        
        bool currencyExists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] = _rateToEth;
    }

    // 提取所有 ETH
    function withdrawTips() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "ETH transfer failed");
    }

    // 提取所有 USDC
    function withdrawUSDC() public onlyOwner {
        uint256 usdcBalance = usdcToken.balanceOf(address(this));
        require(usdcBalance > 0, "No USDC to withdraw");
        bool success = usdcToken.transfer(owner, usdcBalance);
        require(success, "USDC transfer failed");
    }

    // --- 工具函数 ---

    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        return _amount * conversionRates[_currencyCode];
    }

    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }
}
