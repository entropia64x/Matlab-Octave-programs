## Copyright (C) 2019-2020 entropia64x

## -*- texinfo -*-
##
## @deftypefn  {} {} adj (@var{A})
##
## Devuelve la matriz adjunta de la matriz cuadrada @var{A}.
##
## @end deftypefn

## author: entropia64x

function B = adj(A)
  
  if ( nargin ~= 1 )
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
      B(row,column) = (-1)^(row + column)*det(M);
    end
  end
  B = B';
end
