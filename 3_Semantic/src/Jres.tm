
C-MINUS COMPILATION: Jtest.tm

Syntax tree:
  Function declaration : main, return type : int 
    Single parameter, name : (null), type : void
    Curly scope
      Var declaration, name : MonaWallet, type : int 
      Var declaration, name : KeqingWallet, type : int 
      Expression statement
        Assign to first var, Op : =
          Id : KeqingWallet
          Const : 10000
      Expression statement
        Assign to first var, Op : =
          Id : MonaWallet
          Const : 0
      Expression statement
        Assign to first var, Op : =
          Id : MonaWallet
          Call, name : MonaEarn, with argument below
            Op : /
              Id : KeqingWallet
              Const : 10
            Id : MonaWallet
      Return
        Const : 0
  Function declaration : MonaEarn, return type : int 
    Single parameter, name : sallery, type : int
    Single parameter, name : MonaWallet, type : int
    Curly scope
      Return
        Op : +
          Id : sallery
          Id : MonaWallet
