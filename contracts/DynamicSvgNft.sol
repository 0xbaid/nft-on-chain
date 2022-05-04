//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";

contract DynamicSvgNft is ERC721 {
    //mint an nft based off the price of eth

    //if eth > someNumber mint smile svg
    //else frown svg

    uint256 public s_tokenCounter;
    string public s_lowImageURI;
    string public s_highImageURI;
    int256 public immutable i_highValue;
    AggregatorV3Interface public immutable i_priceFeed;

    constructor(
        string memory _highSvg,
        string memory _lowSvg,
        address _priceFeedAddress,
        int256 _highValue
    ) ERC721("Dynaminc SVG NFT", "DSN") {
        s_tokenCounter = 0;
        s_lowImageURI = svgToImageURI(_lowSvg);
        s_highImageURI = svgToImageURI(_highSvg);
        i_priceFeed = AggregatorV3Interface(_priceFeedAddress);
        i_highValue = _highValue;
    }

    function svgToImageURI(string memory _svg)
        public
        pure
        returns (string memory)
    {
        string memory baseImageURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(abi.encodePacked(_svg))
        ); //converting svg to byte code
        return string(abi.encodePacked(baseImageURL, svgBase64Encoded)); //concatenating baseImageurl and bytes svg
    }

    function mintNFT() external {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    //converting the json
    function tokenURI(
        uint256 /*_tokenId*/
    ) public view override returns (string memory) {
        //how do we base64 encode this string to url/uri = using base64.sol (base64:  binary to text encoding)
        //how do we get image; pass svg to constructor, convert it and select based on the price
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        string memory imageUri = s_lowImageURI;
        if (price > i_highValue) {
            imageUri = s_highImageURI;
        }
        bytes memory metaDataTemplate = (
            abi.encodePacked(
                '{"name": "Dynamic SVG", "description":"An NFT that changes based on the Chainlink Feed", "attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                imageUri,
                '"}'
            )
        );
        bytes memory metaDataTemplateInBytes = bytes(metaDataTemplate);
        string memory encodedMetadata = Base64.encode(metaDataTemplateInBytes);
        return (string(abi.encodePacked(_baseURI(), encodedMetadata))); //abi.encodePacked to concatenate strings and type cast bacl to string
    }
}
