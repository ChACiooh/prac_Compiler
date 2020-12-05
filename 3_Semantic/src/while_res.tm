
C-MINUS COMPILATION: while_test.tm

Syntax tree:
  Function declaration : main, return type : int 
    Single parameter, name : (null), type : void
    Curly scope
      Var declaration, name : i, type : int 
      Expression statement
        Assign to first var, Op : =
          Id : i
          Const : 10
      While
        Op : <
          Op : *
            Id : i
            Const : 10
          Const : 100
        Curly scope
          Expression statement
            Assign to first var, Op : =
              Id : i
              Op : +
                Id : i
                Const : 1
      Return
        Const : 0
