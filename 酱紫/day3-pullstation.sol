// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation {
    //string[]数组；mapping映射 – 存储投票计数
    string[] public candidateNames;
    mapping(string => uint256) voteCount;

    // 1. 添加候选人，初始投票数字为0
    function addCandidateNames(string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0;
    }

    // 2. 投票功能，输入名字后投票
    // 注意：这里没有 view，因为我们要“写”数据
    function vote(string memory _candidateNames) public {
        // 逻辑：找到账本里对应名字的票数，执行 +1
        voteCount[_candidateNames] += 1;
    }

    // 3. 查询所有候选人名字
    function checkcandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    // 4. 查询特定人的票数,输入名字后查询
    function checkVote(string memory _candidateNames) public view returns (uint256) {
        return voteCount[_candidateNames];
    }
}
