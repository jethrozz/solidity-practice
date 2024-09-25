// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract insertSort{

    // 2 1 3 6 5
//1
    // 1 2 3 6 5
//2
    // 1 2 3 6 5
//3
    // 1 2 3 6 5
//4
     // 1 2 3 6 6
     // 1 2 3 5 6
    function sort(uint[] memory arr) public pure returns (uint[] memory){
        for(uint i=1; i < arr.length; i++){
            uint temp = arr[i];
            uint j = i;
            while ((j >= 1) && (temp < arr[j-1])){
                arr[j] = arr[j-1];
                j--;
            }
            arr[j] = temp;
        }

        return (arr);
    }
}