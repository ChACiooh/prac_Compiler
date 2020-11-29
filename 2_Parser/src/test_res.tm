
C-MINUS COMPILATION: test.tm

Syntax tree:
  Var declaration, name : a, type : int 
  Var declaration, name : b, type : void , array size : 10
  Function declaration : main, return type : int 
    Single parameter, name : k, type : int
    Single parameter, name : l, type : int
    Curly scope
      Var declaration, name : ccc, type : int 
      Var declaration, name : arr, type : int , array size : 10
      Expression statement
        Assign to first var, Op : =
          Id : arr
            Op : /
              Id : l
              Const : 10
          Assign to first var, Op : =
            Id : ccc
            Id : k
      If
        Op : <
          Id : ccc
          Const : 1000
        Return
          Const : 10
      If
        Op : ==
          Id : ccc
          Const : 1000
        Return
          Const : 20
        Return
          Const : 30
