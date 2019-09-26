pragma solidity ^0.4.25;

contract Hui {
    struct Member {
        string name;
        address wallet_address;
        bool withdrawed;
        bool king;
        bool speeched;
        string speech;
    }

    Member[] public members;
    string last_message;
    mapping (address => uint) public memberToId;
    mapping (address => bool) public memberVoted;
    mapping (address => uint8) public votedCount;
    mapping (uint => uint) public roundVoted;
    uint needed = 3;
    uint max = 0;
    uint max_id = 0;
    uint FEE = 0.001 ether;
    modifier inGroup() {
        memberToId[msg.sender];
        require(memberToId[msg.sender] > 0);
        _;
    }

    event NewMember(address _user, string _name, bool _king);
    event Voted(address _from, address _to);
    event TransferMoneyToVoted(address _to);
    event signedUp(address _from, string _name);
    event speeched(uint memId);
    event startVote();
    event voteUpdate(uint vote1, uint vote2, uint vote3);

    function signUp(string _name) external {
        if(members.length == 0 || (memberToId[msg.sender] == 0 && members.length < 3)) {
            emit signedUp(msg.sender, _name);
            createMember(_name);
        } else if (members.length == 3) {
            emit startVote();
        }
    }

    function checkMemberToID() public view returns (uint) {
        return memberToId[msg.sender];
    }

    function createMember(string memory _name) internal {
        uint id = 0;
        if(members.length == 0) {
            id = members.push(Member(_name, msg.sender, false, true, false, ''));
            emit NewMember(msg.sender, _name, true);
        } else {
            id = members.push(Member(_name, msg.sender, false, false, false, ''));
            emit NewMember(msg.sender, _name, false);
        }
        memberToId[msg.sender] = id;
    }

    function getMembers() public view returns (uint) {
        return members.length;
    }

    function speeching(string _message) external inGroup() {
        members[memberToId[msg.sender] - 1].speech = _message;
        emit speeched(memberToId[msg.sender]);
    }

    function getMemberDetails(uint id) public view returns (address, string, bool, bool, bool, string) {
        return (members[id].wallet_address, members[id].name, members[id].withdrawed, members[id].king, members[id].speeched, members[id].speech);
    }

    function getMemberDetailsByAddress(address _from) public view returns (uint) {
        return memberToId[_from];
    }

    function _transfer(address _to) external payable {
        _to.transfer(1 ether);
    }

    function viewBalance() public view returns (uint) {
        return address(this).balance;
    }

    function sendMoneyToWinner() external payable {
        require(max > 0);
        members[max_id].wallet_address.transfer(msg.value);
    }

    function _transferComplete(address _to) public {
        require(members[memberToId[msg.sender] -1].king);
        members[memberToId[_to] -1].withdrawed = true;
    }

    function vote(address _to) public inGroup() {
        require(members.length == 3);
        uint round = members.length - needed + 1;
        if(!memberVoted[msg.sender] && !members[memberToId[_to] - 1].withdrawed) {
            memberVoted[msg.sender] = true;
            votedCount[_to] = votedCount[_to] + 1;
            if(max < votedCount[_to]) {
                max = votedCount[_to];
                max_id = memberToId[_to] -1;
            }
            roundVoted[round]++;
            emit voteUpdate(votedCount[members[0].wallet_address], votedCount[members[1].wallet_address], votedCount[members[2].wallet_address]);
        }

        if(roundVoted[round] == needed) {
            emit TransferMoneyToVoted(members[max_id].wallet_address);
        }
    }
}
