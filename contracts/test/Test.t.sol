pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract ContractTest is Test {
  address internal constant zero = 0x0000000000000000000000000000000000000000;
  uint256 internal testNumber;

  function setUp() public {}

  // Converts 0x050308000... into 0x5380...
  function removeEveryTwo(bytes memory b) internal returns (bytes memory out) {
    assembly {
      out := mload(0x40)
      let lenB := mload(b)
      for {
        let i := 0
      } lt(i, lenB) {
        i := add(i, 2)
      } {
        // Isolates every 2 bytes (by rightshifting the next word by 240/256 bits), then extract the last 4 bits and keep them around, and add them to a 4 bit-right shifted middle 4 bits, to remove the 0s in between
        mstore8(add(out, add(0x20, shr(1, i))), add(mod(shr(240, mload(add(b, add(0x20, i)))), 16), shr(4, and(0x0f00, shr(240, mload(add(b, add(0x20, i))))))))
      }
      let lenOut := div(lenB, 2)
      mstore(out, lenOut)
      mstore(0x40, add(out, add(0x20, shl(5, shr(5, add(lenOut, 0x1f))))))
    }
  }

  //   function removeEveryOtherHalfByte(bytes memory data) public pure returns (bytes memory result) {
  //     assembly {
  //       let len := mload(data)
  //       result := mload(0x40)
  //       mstore(result, len)
  //       mstore(0x40, add(result, add(32, len)))
  //       let i := 0
  //       for {

  //       } lt(i, len) {
  //         i := add(i, 2)
  //       } {
  //         mstore8(add(result, add(32, i)), byte(0, mod(shr(248, mload(add(data, add(32, i)))), 16)))
  //       }
  //       mstore(result, div(len, 2))
  //       mstore(0x40, add(result, add(0x20, shl(5, shr(5, add(div(len, 2), 0x1f))))))
  //     }
  //   }

  function testAddressEncodingValue() public {
    bytes memory key = hex"050308000c070b070a0e08010a05080e0b09080d090c07080d0e040a010f0d070f0d090503050f0c0905030e0d020b0e0600020d0a0a0a04010706070301020a";
    console.logBytes32(keccak256(abi.encodePacked(zero)));
    // console.logBytes(removeEveryOtherByte(key));
    emit log_named_bytes("out", removeEveryTwo(key));
    emit log_named_bool("out2", removeEveryTwo(key) == keccak256(abi.encodePacked(zero)));
    return;
    // bytes32 origHashedAddress = keccak256(abi.encodePacked(zero));
    // bytes32 hashedAddress = keccak256(abi.encodePacked(zero));
    // bytes memory addressKey = hex"00";
    // for (uint16 i = 0; i < 256 / 4; i++){
    //     addressKey += (hashedAddress % 16) * (1 << (8 * i));
    //     hashedAddress /= 16;
    // }
    // console.logBytes(addressKey);
  }
}
