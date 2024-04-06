// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;
pragma abicoder v2;

import "base64-sol/base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTDescriptor {
    using Strings for uint256;
    struct ConstructTokenURIParams {
        uint256 tokenId;
        uint256 amount;
        uint256 issueAt;
        address user;
    }

    function constructTokenURI(
        ConstructTokenURIParams memory params
    ) public pure returns (string memory) {
        uint256 amountEther = params.amount / 1000000000000000000;
        string memory etherString = Strings.toString(amountEther);
        uint256 startAmount = params.amount - amountEther * 1000000000000000000;
        uint256 amountPoint = params.amount - amountEther * 1000000000000000000;
        uint256 amountDiv = 1000000000000000000;
        uint256 newAmountPoint = params.amount - (amountEther * amountDiv);
        if (newAmountPoint != 0) etherString = string(abi.encodePacked(Strings.toString(amountEther), '.'));
        while (newAmountPoint != 0) {
          amountDiv = amountDiv / 10;
          amountPoint = startAmount / amountDiv;
          etherString = string(abi.encodePacked(etherString, Strings.toString(amountPoint)));
          newAmountPoint = startAmount - amountPoint * amountDiv;
        }
        string memory image = Base64.encode(bytes(generateSVG(params, etherString)));
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "GroFi Staking"',
                                ', "amount":"',
                                Strings.toString(params.amount),
                                '", "issueAt": "',
                                Strings.toString(params.issueAt),
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function generateSVG(
        ConstructTokenURIParams memory params, string memory amount
    ) private pure returns (string memory svg) {
        uint256 str1length = bytes(Strings.toString(params.tokenId)).length + 4;
        uint256 str2length = bytes(Strings.toString(params.issueAt)).length + 10;
        uint256 str3length = bytes(amount).length + 10;
        svg = string(
            abi.encodePacked(
                string(
                    abi.encodePacked(
                        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="290" height="500">',
                        "<defs>",
                        '<clipPath id="corners">',
                        '<rect width="290" height="500" rx="42" ry="42" />',
                        "</clipPath>",
                        '<path id="text-path-a" d="M40 12 H250 A28 28 0 0 1 278 40 V460 A28 28 0 0 1 250 488 H40 A28 28 0 0 1 12 460 V40 A28 28 0 0 1 40 12 z" />',
                        "</defs>",
                        '<g clip-path="url(#corners)">',
                        '<rect width="290" height="500" x="0px" y="0px" fill="#000000" />',
                        '<mask id="mask1_861_14058" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="148" y="170" width="24" height="62">',
                          '<path d="M157.151 216.775V184.786L163.408 188.391V213.17L157.151 216.775ZM148.597 170.004V231.557L171.962 218.098V183.463L148.597 170.004Z" fill="white" />',
                        '</mask>',
                        '<g mask="url(#mask1_861_14058)">',
                          '<path d="M171.962 170.004H148.597V231.557H171.962V170.004Z" fill="#8EF102" />',
                        '</g>',
                        '<path d="M129.171 188.385V213.167L135.434 216.774V200.333L143.986 205.278V231.561L120.618 218.102V183.459L143.967 170H143.986V179.861L135.434 184.777L133.336 185.989L129.171 188.385Z" fill="#8EF102" />',
                        '<path d="M224.63 258.582C221.725 258.582 219.373 260.772 219.373 263.446C219.373 266.144 221.725 268.334 224.63 268.334H227.143V264.853H223.247V261.671H230.578V271.516H224.63C220.088 271.516 215.915 268.173 215.915 263.446C215.915 258.72 220.111 255.4 224.63 255.4H230.578V258.582H224.63Z" fill="white" />',
                        '<path d="M210.168 255.331H213.603V271.493H209.983L204.288 261.717V271.493H200.83V255.331H204.565L210.168 264.922V255.331Z" fill="white" />',
                        '<path d="M198.524 259.273H195.065V255.354H198.524V259.273ZM195.065 271.493V262.455H198.524V271.493H195.065Z" fill="white" />',
                        '<path d="M192.755 255.331L186.483 261.902L192.086 271.493H188.074L184.016 264.507L183.394 265.152V271.493H179.936V255.331H183.394V260.149L187.982 255.331H192.755Z" fill="white" />',
                        '<path d="M172.598 255.4L177.624 271.493H174.028L171.469 263.101H171.446L170.754 260.795L168.218 268.818H168.241L167.411 271.493H163.791L168.909 255.4H172.598Z" fill="white" />',
                        '<path d="M151.139 255.331H164.695V258.651H151.139V255.331ZM159.646 271.493H156.211V262.109H159.646V271.493Z" fill="white" />',
                        '<path d="M145.116 261.671C148.021 261.671 150.396 263.838 150.396 266.467V266.697C150.396 269.326 148.021 271.493 145.116 271.493H137.646V268.265H145.116C146.107 268.265 146.937 267.55 146.937 266.697V266.467C146.937 265.591 146.107 264.899 145.116 264.899H141.289C138.384 264.899 136.009 262.732 136.009 260.103C136.009 257.452 138.384 255.285 141.289 255.285H148.367V258.512H141.289C140.274 258.512 139.467 259.227 139.467 260.103C139.467 260.956 140.274 261.671 141.289 261.671H145.116Z" fill="white" />',
                        '<path d="M126.788 259.273H123.33V255.354H126.788V259.273ZM123.33 271.493V262.455H126.788V271.493H123.33Z" fill="white" />',
                        '<path d="M110.07 255.4H120.999V258.582H113.529V271.493H110.07V255.4ZM120.999 265.36H117.102V262.178H120.999V265.36Z" fill="white" />',
                        '<path d="M100.295 254.962C104.283 254.962 107.765 258.005 107.765 262.086V264.876C107.765 268.934 104.26 272 100.295 272C96.3293 272 92.8018 268.957 92.8018 264.876V262.086C92.8018 257.982 96.3062 254.962 100.295 254.962ZM104.307 264.876V262.086C104.307 259.965 102.508 258.236 100.295 258.236C98.0585 258.236 96.2601 259.965 96.2601 262.086V264.876C96.2601 266.997 98.0585 268.703 100.295 268.703C102.508 268.703 104.307 266.997 104.307 264.876Z" fill="white" />',
                        '<path d="M91.1885 261.072C91.1885 263.331 89.8282 265.291 87.8454 266.213L90.8657 271.447H86.9232L84.2257 266.812H81.8971V271.493H78.4387V263.469H85.2401C86.6235 263.469 87.7532 262.386 87.7532 261.072C87.7532 259.734 86.6235 258.651 85.2401 258.651H82.2429L75.8334 258.559H70.7151C67.81 258.559 65.4584 260.749 65.4584 263.423C65.4584 266.121 67.81 268.311 70.7151 268.311H73.2281V264.83H69.3317V261.648H76.6634V271.493H70.7151C66.1731 271.493 62 268.15 62 263.423C62 258.697 66.1961 255.377 70.7151 255.377H75.8334L85.2401 255.331C88.5371 255.331 91.1885 257.913 91.1885 261.072Z" fill="white" />',
                        "</g>",
                        '<text text-rendering="optimizeSpeed">',
                        '<textPath startOffset="-100%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Staking',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="0%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Staking',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="50%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Staking',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="-50%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Staking',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="25%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Staking',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="-75%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Staking',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="-25%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Staking',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="75%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Staking',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        "</text>",
                        '<g style="transform:translate(29px, 384px)">',
                        '<rect width="',
                        uint256(7 * (str1length + 4)).toString(),
                        'px" height="26px" rx="8px" ry="8px" fill="#272727" />',
                        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">',
                        '<tspan fill="rgba(255,255,255,0.6)">ID: </tspan>',
                        Strings.toString(params.tokenId),
                        "</text>",
                        "</g>",
                        '<g style="transform:translate(29px, 414px)">',
                        '<rect width="',
                        uint256(7 * (str2length + 4)).toString(),
                        'px" height="26px" rx="8px" ry="8px" fill="#272727" />',
                        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">',
                        '<tspan fill="rgba(255,255,255,0.6)">Issue At: </tspan>',
                        Strings.toString(params.issueAt),
                        "</text>",
                        "</g>",
                        '<g style="transform:translate(29px, 444px)">',
                        '<rect width="',
                        uint256(7 * (str3length + 8)).toString(),
                        'px" height="26px" rx="8px" ry="8px" fill="#272727" />',
                        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">',
                        '<tspan fill="rgba(255,255,255,0.6)">Amount: </tspan>',
                        amount,
                        " U2U</text>",
                        "</g>",
                        "</svg>"
                    )
                )
            )
        );
    }
}
