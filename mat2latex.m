## Copyright (C) 2019-2020 entropia64x

## -*- texinfo -*-
##
## @deftypefn  {} {} mat2latex (@var{matriz})
## @deftypefnx {} {} mat2latex (@var{matriz}, @var{num_col})
##
## Devuelve una el codigo en LaTeX de una matriz 
## numerica @var{matriz}.
## 
## Si se desea convertir una matriz de caracteres,
## debe estar en formato de celda.
## @example
## @group
## matriz = {'x1', 'x2', 'x3')
## mat2latex(matriz)
## @end group
## @end example
##
## Si se desea una matriz aumentada con separacion | en
## la k-esima columna escribimos @var{num_col} = k.
## @example
## @group
## matriz = magic(3)
## b = [1;2;3];
## aumentada = [matriz b];
## mat2latex(aumentada,3)
## @end group
## @end example
##
## @end deftypefn

## author: entropia64x

function codigo = mat2latex(matriz,varargin)
  
  if ( nargin < 1 || nargin > 4 )
    print_usage();
  elseif ( ~ismatrix(matriz) && ~iscellstr(matriz) )
    error('El primer termino debe ser una matriz numerica o una celda de caracteres.');
  else
    [num_col, tipo] = esAumentadaQueDelimitadores(matriz,varargin);
  end
  
  eranumerica = isnumeric(matriz);
  
  if ( eranumerica )
    x = ones(1,rows(matriz));
    y = ones(1,columns(matriz));
    matriz = mat2cell(matriz,x,y);
  end
  
  codigo = LaTeX(matriz,eranumerica,num_col,tipo);
endfunction

function [num_col, tipo] = esAumentadaQueDelimitadores(matriz,argEntrada)
  
  num_col = false; 
  tipo = 'p';
  
  while( ~isempty(argEntrada) ) 
 
    tiposdeMatriz = {'p','b','v','B','V','none'}; 
    if( ~isempty(find (strcmpi (argEntrada{1}, tiposdeMatriz),1)) )
      tipo = argEntrada{1};
      if ( tipo == 'none' )
        tipo = '';
      end
    elseif ( isscalar(argEntrada{1}) )
      num_col = argEntrada{1};
      if ( num_col - fix(num_col) || num_col < 1 || num_col > columns(matriz) - 1 )
        error("El numero debe ser entero positivo mayor menor que el numero de columas de la matriz");
      end
    else
      print_usage();
    end
    
    argEntrada(1) = [];
  end
  
end

function codigo = LaTeX(matriz, eranumerica, num_col, tipo)
  
  codigo = '';
  codigo = [codigo '\begin{' tipo 'matrix}'];
  
  for  ( ren = 1:rows(matriz) )
    for ( col = 1:columns(matriz) )
      if ( eranumerica )
        entrada = strtrim(rats(matriz{ren,col}));
      else
        entrada = matriz{ren,col};
      end
     
      if ( num_col && col == num_col + 1 )
          codigo = [codigo '|&' entrada];
      else
        codigo = [codigo entrada];
      end
      
      if ( col < columns(matriz) )
        codigo = [codigo '&'];
      elseif ( ren < rows(matriz) )
        codigo = [codigo '\\'];
      end
      
    end
  end
  
  codigo = [codigo '\end{' tipo 'matrix}'];
  codigo = strrep(codigo,"-0&","0&");
end
