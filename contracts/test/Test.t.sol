pragma solidity ^0.8.0;
import "forge-std/Test.sol";

contract ContractTest is Test {
    function setUp() public {
        testNumber = 42;
    }

    function testNumberIs42() public {
        assertEq(testNumber, 42);
    }

    function testFailSubtract43() public {
        testNumber -= 43;
    }
}
