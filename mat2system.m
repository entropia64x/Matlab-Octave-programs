## Copyright (C) 2019-2026 entropia64x

## -*- texinfo -*-
##
## @deftypefn  {} {} mat2system (@var{matrix})
## @deftypefnx {} {} mat2system (@var{matrix}, @var{vars})
##
## Returns a string with the LaTeX code of the
## linear system associated to the augmented matrix.
##
## @example
## @group
## A = reshape(1:12, [3, 4])
## @result{}
##    1    4    7   10
##    2    5    8   11
##    3    6    9   12
## mat2system (A)
## @result{}
## x_1 + 2x_2 + 3x_3 = 4 \\
## 5x_1 + 6x_2 + 7x_3 = 8 \\
## 9x_1 + 10x_2 + 11x_3 = 12
## @end group
## @end example
##
## To specify the variables, they must be
## in cell format.
##
## For example:
##
## @example
## @group
## A = reshape(1:12, [3, 4]);
## x = @{'x', 'y', 'z'@};
## mat2system (A, x)
## @result{}
## x + 2y + 3z = 4 \\
## 5x + 6y + 7z = 8 \\
## 9x + 10y + 11z = 12
## @end group
## @end example
##
## @seealso{mat2latex, latex2mat}
## @end deftypefn

## author: entropia64x

function code = mat2system(augmatrix, varargin)
  
  if ( nargin < 1 || nargin > 2 )
    print_usage();
  elseif ( ~ismatrix(augmatrix) && ~iscellstr(augmatrix) )
    error('The notfirst term must be a numeric matrix, or a character cell.')
  end
  
  v = {};
  
  if(nargin == 2)
    v = varargin{1};
    
    if ( ~iscellstr(v) )
      error('The second argument must be a character cell with the desired variables.')
    end
    
    if ( columns(augmatrix) - 1 ~= length(v) )
      error('The number of columns minus one and the number of variables must be de same.')
    end
  end
  
  wasnotcell = isnumeric(augmatrix);
  
  if ( wasnotcell )
    augmatrix = mat2cell(augmatrix, ones(1, rows(augmatrix)), ones(1, columns(augmatrix)));
  end
  
  code = latex(augmatrix, v);
endfunction

function code = latex(augmatrix, v)
  
  code = '';
  totalrows = rows(augmatrix);
  totalcols = columns(augmatrix);
  
  for  ( row = 1:totalrows )
    
    notfirst = false;
    
    for ( col = 1:totalcols )

      entry = augmatrix{row,col};

      if ( isnumeric(entry) )
        entry = strtrim(rats(entry));
      end
      
      if ( col < columns(augmatrix) && ~strcmpi(entry,'0') && ~strcmpi(entry,'-0') )
        if( notfirst )
          if( strfind(entry,'-') )
            code = [code ' - '];
          else
            code = [code ' + '];
          end
        end
        
        if( ~( strcmpi(entry,'1') || strcmpi(entry,'-1') ) )
          if ( notfirst )
            entry = strrep(entry, '-', '');
          end

          code = [code entry];
        elseif( strcmpi(entry,'-1') )
          code = [code '-'];
        end

        notfirst = true;
        
        if ( isempty(v) )
          code = [code 'x_' num2str(col)];
        else
          code = [code v{col}];
        end
      
      elseif ( col == columns(augmatrix) )
        code = [code ' = ' entry];
        if ( row < rows(augmatrix) )
            code = [code ' \\ '];
        end
      end
    end
  end

end
