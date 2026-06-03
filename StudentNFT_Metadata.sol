// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StudentNFTMetadata {

    struct NFT {
        uint256 tokenId;
        string metadataCID;
        address owner;
    }

    uint256 public nextTokenId;

    mapping(uint256 => NFT) public nfts;

    function createNFT(string memory _metadataCID) public {

        nextTokenId++;

        nfts[nextTokenId] = NFT({
            tokenId: nextTokenId,
            metadataCID: _metadataCID,
            owner: msg.sender
        });
    }

    function getMetadataURI(uint256 _tokenId) public view returns (string memory) {

        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/",
                nfts[_tokenId].metadataCID
            )
        );
    }
}