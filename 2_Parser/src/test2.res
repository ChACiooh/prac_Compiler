C-MINUS COMPILATION: test2.tm

Syntax tree:
  Var declaration, name : arr, type : int[] 
    size : 100
  Var declaration, name : ar, type : int[] 
    size : 0
  Function declaration : main, return type : void 
    Single parameter, name : (null), type : void
    Curly scope
      Var declaration, name : d, type : int[] 
        size : 10
      Var declaration, name : arr, type : int[] 
        size : 10
      If
        Op : <
          Id : a
          Const : 0
        Curly scope
          If
            Op : >
              Id : a
              Const : 3
            Expression statement
              Assign to first var, Op : =
                Id : a
                Const : 3
            Expression statement
              Assign to first var, Op : =
                Id : a
                Const : 4
          Expression statement
            Assign to first var, Op : =
              Id : a
              Const : 5
        Curly scope
          Var declaration, name : arr, type : int[] 
            size : 3
          Var declaration, name : arr, type : int[] 
            size : 10
      Expression statement
        Assign to first var, Op : =
          Id : a
          Assign to first var, Op : =
            Id : b
            Assign to first var, Op : =
              Id : c
              Const : 3
  Function declaration : main, return type : int 
    Single parameter, name : (null), type : void
    Curly scope
      Var declaration, name : a, type : int 
      Var declaration, name : b, type : int 
      Expression statement
        Assign to first var, Op : =
          Id : c
          Op : +
            Id : a
            Id : b
      Expression statement
        Assign to first var, Op : =
          Id : ans
            Const : 100
          Id : a
      Expression statement
        Assign to first var, Op : =
          Id : a
            Id : i
          Id : ans
            Id : b
      Expression statement
        Call, name : func, with argument below
          Assign to first var, Op : =
            Id : a
            Id : b
          Const : 3
          Op : *
            Id : a
            Id : b
          Id : arr
            Id : a
