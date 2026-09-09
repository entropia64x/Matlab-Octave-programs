## Copyright (C) 2019-2021 entropia64x

## -*- texinfo -*-
##
## @deftypefn  {} {} mat2system (@var{matrizaum})
## @deftypefnx {} {} mat2system (@var{matrizaum}, @var{variables})
##
## Devuelve el codigo en LaTeX del sistema lineal
## asociado a la matriz aumentada @var{matrizaum}.
## 
## Si se desean especificar los caracteres, 
## debe estar en formato de celda.
## @example
## @group
## A = magic(3);
## b = [1 2 3]';
## x = @{'x', 'y', 'z'@}
## mat2system([A b],x)
## @end group
## @end example
##
## @end deftypefn

## author: entropia64x

function codigo = mat2system(matrizaum,varargin)
  
  if ( nargin < 1 || nargin > 2 )
    print_usage();
  elseif ( ~ismatrix(matrizaum) && ~iscellstr(matrizaum) )
    error('El primer termino debe ser una matriz numerica o una celda de caracteres.');
  end
  
  v = {};
  
  if(nargin == 2)
    v = varargin{1};
    
    if ( ~iscellstr(v) )
      error("El segundo argumento debe ser una celda de caracteres con las variables");
    end
    
    if ( columns(matrizaum) - 1 ~= length(v) )
      error("El numero de columnas menos uno y de variables debe coincidir") 
    end
  end
  
  eranumerica = isnumeric(matrizaum);
  
  if ( eranumerica )
    x = ones(1,rows(matrizaum));
    y = ones(1,columns(matrizaum));
    matrizaum = mat2cell(matrizaum,x,y);
  end
  
  codigo = LaTeX(matrizaum,eranumerica,v);
endfunction

function codigo = LaTeX(matrizaum, eranumerica,v)
  
  codigo = '';
  
  for  ( ren = 1:rows(matrizaum) )
    
    primero = false;
    
    for ( col = 1:columns(matrizaum) )
      
      if ( eranumerica )
        entrada = strtrim(rats(matrizaum{ren,col}));
      else
        entrada = matrizaum{ren,col};
      end
      
      if ( col < columns(matrizaum) && ~strcmpi(entrada,'0') && ~strcmpi(entrada,'-0') )
      
        if( primero && isempty(strfind(entrada,'-')) )
          codigo = [codigo '+'];
        end
        
        primero = true;
        
        if( ~( strcmpi(entrada,'1') || strcmpi(entrada,'-1') ) )
          codigo = [codigo entrada];
        elseif( strcmpi(entrada,'-1') )
          codigo = [codigo '-'];
        end
        
        if ( isempty(v) )
          codigo = [codigo 'x_' num2str(col)];
        else
          codigo = [codigo v{col}];
        end
      
      elseif ( col == columns(matrizaum) )
        codigo = [codigo '=' entrada];
        if ( ren < rows(matrizaum) )
            codigo = [codigo '\\'];
        end
      end
    end
  end

end
