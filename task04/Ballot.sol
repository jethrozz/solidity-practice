// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Ballot{
    //事件定义
    event VoteWeightChange(address voterAddress, uint weight);

    //错误定义
    //初始化时间范围校验
    error InvalidTimeRange();
    //时间检测错误
    error NotInTimeRange();
    // 操作权限校验
    error NotChairMan(address sender);
    error AddressVoted(address addr);
    error WeightIsNotZero();

    //结构体定义
    struct Voter {
        uint weight; //计票权重
        bool voted;  //是否已经投票
        address delegate; //被委托人
        uint vote; // 投票提案的索引
    }
    struct Proposal {
        bytes32 name;  //提案名称
        uint voteCount; // 票数
    }
    //允许投票的开始时间
    uint256 private  startTime;
    //允许投票的结束时间
    uint256 private endTime;
    //合约拥有者
    address private owner;
    //记录投票
    mapping(address => Voter) voterMap;

    Proposal[] public proposalsList;

    constructor(bytes32[] memory proposalNames, uint256 _startTime, uint256 _endTime){
        owner = msg.sender;
        voterMap[owner].weight = 1;

        if(endTime < startTime){
            revert InvalidTimeRange();
        }
        endTime = _endTime;
        startTime = _startTime;
        for(uint i = 0; i< proposalNames.length; i++){
            proposalsList.push(Proposal({
                name:proposalNames[i],
                voteCount:0
                }));
        }
    }

    //投票权授予
    function giveRightToVote(address voterAddress) external {
        _checkTime();


        if(!voterMap[voterAddress].voted){
            revert AddressVoted(msg.sender);
        }
        if(voterMap[voterAddress].weight != 0){
            revert WeightIsNotZero();
        }
        voterMap[voterAddress].
    }
    //主动投票
    function vote(uint proposalIndex) external {
        _checkTime();
    }
    //委托投票
    function delegateVote(address delegateAddress)external {
        _checkTime();
    }
    //
    function getWinner()public view returns (bytes32 winnerName){
        //计算最多的票数
        //票数计算规则为 
    }
    function _checkTime() internal view {
        uint256 currTime = block.timestamp;
        if(currTime < startTime || currTime > endTime){
            revert NotInTimeRange();
        }
    }

    function _checkChairMan()

    //设置某人权重
    function setVoterWeight(address voterAddress, uint weight)external {
        _checkTime();
        voterMap[voterAddress].weight = weight;
        emit VoteWeightChange(voterAddress, weight);
    }
}