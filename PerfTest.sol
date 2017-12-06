pragma solidity ^0.4.11;

/*
Use constant modifier if your function does not modify storage and 
constant if it does not even read any state information
*/

contract PerfTest
{
   address public _owner;

   // Constructor
   function PerfTest() public {
    _owner = msg.sender;
   }
 
  /*======================= STORAGE RELATED PATTERNS ========================================================
    ======================================================================================================*/

  /* Useless code :  dead code*/
   function DeadCode ( uint x ) public constant {
    if ( x > 5)
      if ( x*x < 20){
        //Do someting : but this code will never be executed
      }
  }

   /* Useless code :  opaque predicate*/
   function OpaquePredicate ( uint x ) public constant {
      if ( x > 5)
        if ( x > 1){ //opaque predicate
            /*Do someting: the previous test is irrelevant,  this code will always be executed or not 
              independently of the outcome of the previous test */ 
        } 
    }

  /*======================= LOOP RELATED PATTERNS ========================================================
  /* Remix advise/warning:
    If the gas requirement of a function is higher than the block gas limit, it cannot be executed. 
    Please avoid loops in your functions or actions that modify large areas of storage 
    (this includes clearing or copying arrays in storage)
  /*======================================================================================================
     Expensive operations in a loop.
     -------------------------------
    The variable sum is stored in the storage, The summation  involves
    ==> a SLOAD for loading sumBad to the stack 
    ==> a SSTORE for saving the outcome of the ADD to the storage. 
    Storage-related operations are very expensive.
    An advanced compiler should assign sum to a local variable (e.g., tmp) that resides in the stack,
    then add i to tmp inside the loop, and finally assign tmp to sum after the loop. Such optimization 
    reduces the storage-related operations from 2x to just 2, i.e., one SLOAD and one SSTORE.
    ======================================================================================================*/
  
    uint public sumBad=0;
    function loopBad () public returns ( uint ){
      for ( uint i = 1 ; i <= 100 ; i++)
        sumBad += i;
      return sumBad; 
    }

    
    function loopGood () public  returns ( uint ){
      uint sum=0;
      for ( uint i = 1 ; i <= 100 ; i++)
        sum += i;
      return sum; 
    }
    
   /*======================================================================================================
     Constant outcome of a loop
     -------------------------------
    In some cases, the outcome of a loop may be a constant that can be inferred in compilation.
    As shown in Fig.2 (Pattern 4), the storage variable sumBad equals to 5050 after the loop. 
    Hence, the body of p4 should be simplified as “return 5050;”.
    ======================================================================================================*/
  
  function loop2Bad () public  returns ( uint ){
      uint sum = 0;
      for ( uint i = 1 ; i <= 100 ; i++)
        sum += i;
      return sum; 
  }

  function loop2Good () public  returns ( uint ){
      return 5050; 
  }

  /*============================================================================================
   Comparison with unilateral outcome in a loop
   --------------------------------------------
   Loop fusion. It combines several loops into one if possible and thus reduces the size of bytecode. 
   In particular, it can reduce the amount of operations, such as conditional jumps and comparison, etc., 
   at the entry points of loops. The two loops shown hereunder can be combined into one loop, 
   where both m and v get updated.
  ============================================================================================*/
  function  LoopFusionBad( uint x ) public  {
    
    uint m = 0;
    uint v = 0;
    for ( uint i = 0 ; i < x ; i++)
        m += i;

    for ( uint j = 0 ; j < x ; j++)
        v -= j; 
  }

  function  LoopFusionGood( uint x ) public  {
    
    uint m = 0;
    uint v = 0;
    for ( uint i = 0 ; i < x ; i++){
        m += i;
        v -= i; 
    }
  }

  /*============================================================================================
   Repeated computations in a loop. 
   In some cases, there may be expressions that produce the same outcome in each
   iteration of a loop. Hence, the gas can be saved by computing the outcome once and then 
   reusing the value instead of recomputing it in subsequent iterations, especially, for the
   expressions involving expensive operands. 
   In this example, the gas consumption is very high due to the repeated computations. 
   More precisely, the summation of two storage words (i.e., “x+y”) is quite expensive because 
   x and y should be loaded into the stack (i.e., SLOAD) before addition. To save gas, this 
   summation should be finished before the loop, and then the result is reused within the loop
  ============================================================================================*/
  uint x = 1;
  uint y = 2;
  function RepeatedComputationBad ( uint k ) public  {
    
    uint sum = 0;
    for ( uint i = 1 ; i <= k ; i++)
      sum = sum + x + y; 
  }

    function RepeatedComputationGood( uint k ) public  {
    
    uint sum = 0;
    uint delta = x+y;
    for ( uint i = 1 ; i <= k ; i++)
      sum = sum + delta; 
  }

  /*=====================================================================================================
   Comparison with unilateral outcome in a loop.
   It means that a comparison is executed in each iteration of a loop but the result of the comparison is 
   the same even if it cannot be determined in compilation (i.e., not an opaque predicate :  
   The outcome of an opaque predicate is known to be true or false without execution). 
   For instance, in Fig.4, the comparison at Line 3 should be moved to the place before the loop.
  ======================================================================================================*/
  function ComparisonBad ( uint xx , uint yy ) public  returns ( uint ){
    
      for ( int i = 0 ; i < 100 ; i++) {
        if ( xx > 0 ) 
          yy += xx;
      }
        
      return y; 
  }

  function ComparisonGood ( uint xx , uint yy ) public  returns ( uint ){
    
    if ( xx > 0 ) 
      for ( int i = 0 ; i < 100 ; i++) {      
          yy +=  xx;
      }
      
      return y; 
  }
}