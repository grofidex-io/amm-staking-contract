// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;
pragma abicoder v2;

import "base64-sol/base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LoanNFTDescriptor {
    using Strings for uint256;
    struct ConstructTokenURIParams {
        uint256 tokenId;
        uint256 amount;
        uint256 amountReturn;
        uint256 issueAt;
        uint256 period;
        uint256 repayTime;
        uint256 annualRate;
        uint256 stakeAmount;
    }

    function convertAmountToString(uint256 amount) internal returns(string memory) {
      uint256 amountEther = amount / 1000000000000000000;
      string memory etherString = Strings.toString(amountEther);
      uint256 startAmount = amount - amountEther * 1000000000000000000;
      uint256 amountPoint = amount - amountEther * 1000000000000000000;
      uint256 amountDiv = 1000000000000000000;
      uint256 newAmountPoint = amount - (amountEther * amountDiv);
      if (newAmountPoint != 0) etherString = string(abi.encodePacked(Strings.toString(amountEther), '.'));
      while (newAmountPoint != 0) {
        amountDiv = amountDiv / 10;
        amountPoint = startAmount / amountDiv;
        etherString = string(abi.encodePacked(etherString, Strings.toString(amountPoint)));
        newAmountPoint = startAmount - amountPoint * amountDiv;
      }
      return etherString;
    }

    function constructTokenURI(
        ConstructTokenURIParams memory params
    ) public returns (string memory) {
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
        string memory image = Base64.encode(bytes(generateSVG(params, etherString, convertAmountToString(params.stakeAmount))));
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "GroFi Loan"',
                                ', "Borrow Amount":"',
                                convertAmountToString(params.amount),
                                ' U2U", "issueAt": "',
                                Strings.toString(params.issueAt),
                                '", "Repay Amount": "',
                                convertAmountToString(params.amountReturn),
                                ' U2U", "Repay Time": "',
                                Strings.toString(params.repayTime),
                                '", "Annual Rate": "',
                                convertAmountToString(params.annualRate),
                                ' %", "Period": "',
                                Strings.toString(params.period),
                                ' days", "image": "',
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
        ConstructTokenURIParams memory params, string memory amount, string memory stakeAmount
    ) private pure returns (string memory svg) {
        uint256 str1length = bytes(Strings.toString(params.tokenId)).length + 4;
        uint256 str2length = bytes(Strings.toString(params.repayTime)).length + 8;

        uint256 str3length = bytes(amount).length + 14;
        uint256 str4length = bytes(stakeAmount).length + 14;
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
                        '<path d="M217.186 251.901H221.122V270.419H216.975L210.45 259.218V270.419H206.487V251.901H210.767L217.186 262.89V251.901Z" fill="white" />',
                        '<path d="M198.081 251.98L203.84 270.419H199.719L196.787 260.803H196.761L195.968 258.162L193.062 267.355H193.089L192.138 270.419H187.99L193.855 251.98H198.081Z" fill="white" />',
                        '<path d="M178.724 251.478C183.294 251.478 187.283 254.965 187.283 259.641V262.837C187.283 267.487 183.268 271 178.724 271C174.18 271 170.139 267.513 170.139 262.837V259.641C170.139 254.939 174.154 251.478 178.724 251.478ZM183.321 262.837V259.641C183.321 257.211 181.26 255.229 178.724 255.229C176.162 255.229 174.101 257.211 174.101 259.641V262.837C174.101 265.268 176.162 267.222 178.724 267.222C181.26 267.222 183.321 265.268 183.321 262.837Z" fill="white" />',
                        '<path d="M159.731 262.494H155.769V251.901H159.731V262.494ZM155.769 266.456H168.29V270.419H155.769V266.456Z" fill="white" />',
                        '<path d="M145.208 256.418H141.245V251.927H145.208V256.418ZM141.245 270.419V260.064H145.208V270.419H141.245Z" fill="white" />',
                        '<path d="M126.077 251.98H138.599V255.626H130.04V270.419H126.077V251.98ZM138.599 263.392H134.134V259.747H138.599V263.392Z" fill="white" />',
                        '<path d="M114.878 251.478C119.449 251.478 123.437 254.965 123.437 259.641V262.837C123.437 267.487 119.422 271 114.878 271C110.335 271 106.293 267.513 106.293 262.837V259.641C106.293 254.939 110.308 251.478 114.878 251.478ZM119.475 262.837V259.641C119.475 257.211 117.414 255.229 114.878 255.229C112.316 255.229 110.255 257.211 110.255 259.641V262.837C110.255 265.268 112.316 267.222 114.878 267.222C117.414 267.222 119.475 265.268 119.475 262.837Z" fill="white" />',
                        '<path d="M104.443 258.479C104.443 261.067 102.885 263.313 100.613 264.369L104.074 270.366H99.5562L96.4656 265.056H93.7975V270.419H89.835V261.226H97.6277C99.2127 261.226 100.507 259.984 100.507 258.479C100.507 256.946 99.2127 255.705 97.6277 255.705H94.1938L86.8499 255.599H80.9854C77.657 255.599 74.9625 258.109 74.9625 261.173C74.9625 264.264 77.657 266.773 80.9854 266.773H83.8648V262.784H79.4004V259.139H87.8009V270.419H80.9854C75.7814 270.419 71 266.588 71 261.173C71 255.758 75.8078 251.954 80.9854 251.954H86.8499L97.6277 251.901C101.405 251.901 104.443 254.859 104.443 258.479Z" fill="white" />',
                        '<mask id="mask1_861_14058" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="147" y="166" width="26" height="68">',
                          '<path d="M156.577 216.914V182.095L163.388 186.018V212.99L156.577 216.914ZM147.267 166.004V233.005L172.7 218.354V180.655L147.267 166.004Z" fill="white" />',
                        '</mask>',
                        '<g mask="url(#mask1_861_14058)">',
                          '<path d="M172.7 166.004H147.267V233.005H172.7V166.004Z" fill="#8EF102" />',
                        '</g>',
                        '<path d="M126.121 186.011V212.987L132.938 216.913V199.017L142.247 204.4V233.008L116.812 218.359V180.65L142.226 166H142.247V176.733L132.938 182.085L130.655 183.404L126.121 186.011Z" fill="#8EF102" />',
                        "</g>",
                        '<text text-rendering="optimizeSpeed">',
                        '<textPath startOffset="-100%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Loan',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="0%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Loan',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="50%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Loan',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="-50%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Loan',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="25%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Loan',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="-75%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Loan',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="-25%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Loan',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        '<textPath startOffset="75%" fill="white" font-family="\'Courier New\', monospace" font-size="11px" xlink:href="#text-path-a">GroFi Loan',
                          '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                        '</textPath>',
                        "</text>",
                        '<g style="transform:translate(29px, 354px)">',
                        '<rect width="',
                        uint256(7 * (str1length + 4)).toString(),
                        'px" height="26px" rx="8px" ry="8px" fill="#272727" />',
                        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">',
                        '<tspan fill="rgba(255,255,255,0.6)">ID: </tspan>',
                        Strings.toString(params.tokenId),
                        "</text>",
                        "</g>",
                        '<g style="transform:translate(29px, 384px)">',
                        '<rect width="',
                        uint256(7 * (str2length + 10)).toString(),
                        'px" height="26px" rx="8px" ry="8px" fill="#272727" />',
                        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">',
                        '<tspan fill="rgba(255,255,255,0.6)">Repay Time: </tspan>',
                        Strings.toString(params.repayTime),
                        "</text>",
                        "</g>",
                        '<g style="transform:translate(29px, 414px)">',
                        '<rect width="',
                        uint256(7 * (str4length + 10)).toString(),
                        'px" height="26px" rx="8px" ry="8px" fill="#272727" />',
                        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">',
                        '<tspan fill="rgba(255,255,255,0.6)">Staked Amount: </tspan>',
                        stakeAmount,
                        " U2U</text>",
                        "</g>",
                        '<g style="transform:translate(29px, 444px)">',
                        '<rect width="',
                        uint256(7 * (str3length + 10)).toString(),
                        'px" height="26px" rx="8px" ry="8px" fill="#272727" />',
                        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">',
                        '<tspan fill="rgba(255,255,255,0.6)">Borrow Amount: </tspan>',
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
