// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Twitter {

    uint16 public MAX_TWEET_LENGTH = 280;

    struct Tweet {
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping(address => Tweet[]) public tweets;

    // 0 = not liked, 1 = liked
    mapping(address => mapping(uint => mapping(address => uint8))) public tweetLikes;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "YOU ARE NOT THE OWNER!");
        _;
    }

    function createTweet(string memory _tweet) public {
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet too long!");

        tweets[msg.sender].push(
            Tweet(msg.sender, _tweet, block.timestamp, 0)
        );
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }

    // LIKE / UNLIKE TOGGLE
    function toggleLike(address _author, uint _index) public {
        require(_index < tweets[_author].length, "Tweet not found");

        if (tweetLikes[_author][_index][msg.sender] == 0) {
            // Like
            tweets[_author][_index].likes++;
            tweetLikes[_author][_index][msg.sender] = 1;
        } else {
            // Unlike
            tweets[_author][_index].likes--;
            tweetLikes[_author][_index][msg.sender] = 0;
        }
    }
}
