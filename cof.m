## Copyright (C) 2019-2026 entropia64x

## -*- texinfo -*-
##
## @deftypefn  {} {} cof (@var{A})
## @deftypefnx  {} {} cof (@var{A}, true)
## Devuelve la matriz de cofactores de la matriz cuadrada @var{A}.
##
## Si el segundo argumento está presente, entonces
## se muestran todas las matrices menores.
##
## @end deftypefn

## author: entropia64x

function B = cof(A, minor = false)

  if( nargin < 1 || nargin > 2 )
    print_usage();
  end
  
  if ( ~size_equal(A) )
    error("Debe ser una matriz cuadrada")
  end
  
  B = A;
  
  for ( row = 1:size(A,1) )
    auxMatrix = A;
    auxMatrix(row,:) = [];
    for( column = 1:size(A,2) )
      M = auxMatrix;
      M(:,column) = [];
      B(row,column) = (-1)^(row+column)*det(M);
      if ( minor )
        printf("M%d%d = \n",row,column);
        disp(M);
      end
    end
  end
end
