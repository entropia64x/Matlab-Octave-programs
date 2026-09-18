## Copyright (C) 2019-2026 entropia64x

## -*- texinfo -*-
##
## @deftypefn  {} {} mat2latex (@var{matrix})
## @deftypefnx {} {} mat2latex (@var{matrix}, @var{col_num})
## @deftypefnx  {} {} mat2latex (@var{matrix}, @var{mtype})
## @deftypefnx  {} {} mat2latex (@var{matrix}, @var{col_num}, @var{mtype})
##
## Returns the LaTeX code of a matrix @var{matrix}.
##
## If it's a character matrix, it must be in cell format.
## @example
## @group
## M = @{'a', 'b';'c', 'd'@};
## mat2latex (M)
## @result{}
## \begin@{pmatrix@}
## a & b \\
## c & d
## \end@{pmatrix@}
## @end group
## @end example
##
## If it's an augmented matrix with separation | in the
## k-th column, we write  @var{col_num} = k.
## @example
## @group
## A = reshape (1:6, [3, 2])'
## @result{}
##   1   2   3
##   4   5   6
## mat2latex (A, 2)
## @result{}
## \begin@{pmatrix@}
## 1 & 2 & | & 3 \\
## 4 & 5 & | & 6
## \end@{pmatrix@}
## @end group
## @end example
##
## We can specify the type of delimiters we want to use
## by writing 'p','b','v','B','V', or 'none'. By default
## @var{mtype} = 'p'.
##
## @example
## @group
## mat2latex (magic(2), 'v')
## @result{}
## \begin@{vmatrix@}
## 4 & 3 \\
## 1 & 2
## \end@{vmatrix@}
## @end group
## @end example
##
## We also can use both @var{col_num} and @var{mtype} in any order.
##
## @seealso{latex2mat, mat2system}
## @end defmtypefn

## author: entropia64x

function latexcode = mat2latex(matrix, varargin)
  
  if ( nargin < 1 || nargin > 4 )
    print_usage();
  elseif ( ~ismatrix(matrix) && ~iscellstr(matrix) )
    error('The first term must be a numeric matrix or a string cell.');
  else
    [col_num, mtype] = analyzeVarargin(matrix, varargin);
  end
  
  wasnotcell = isnumeric(matrix);
  
  if ( wasnotcell )
    matrix = mat2cell(matrix, ones(1, rows(matrix)), ones(1, columns(matrix)));
  end
  
  latexcode = LaTeX(matrix, col_num, mtype);
endfunction

function [col_num, mtype] = analyzeVarargin(matrix, argIn)

  col_num = false; 
  mtype = 'p';
  
  while( ~isempty(argIn) ) 

    kindOfMatrix = {'p','b','v','B','V','none'};
    if ( ischar(argIn{1}) )
      if ( ~isempty(find (strcmpi (argIn{1}, kindOfMatrix), 1)) )
        mtype = argIn{1};
        if ( mtype == 'none' )
          mtype= '';
        end
      else
        error("MTYPE must be 'p','b','v','B','V or 'none'");
      end
    elseif ( isscalar(argIn{1}) )
      col_num = argIn{1};
      if ( col_num - fix(col_num) || col_num < 1 || col_num > columns(matrix) - 1 )
        error('The number must be a positive integer less than the number of matrix columns');
      end
    else
      error("The second argument must be a positive integer or 'p','b','v','B','V, 'none'");
    end
    
    argIn(1) = [];
  end
  
end

function latexcode = LaTeX(matrix, col_num, mtype)
  
  latexcode = "\n";
  latexcode = [latexcode '\begin{' mtype 'matrix}' "\n"];
  
  totalrows = rows(matrix);
  totalcols = columns(matrix);
  
  for  ( row = 1:totalrows )
    for ( col = 1:totalcols )
        
      entry = matrix{row,col};
      if ( isnumeric(entry) )
        entry = strtrim(rats(entry));
      end
     
      if ( col_num && col == col_num + 1 )
          latexcode = [latexcode '| & ' entry];
      else
        latexcode = [latexcode entry];
      end
      
      if ( col < totalcols )
        latexcode = [latexcode ' & '];
      elseif ( row < totalrows )
        latexcode = [latexcode ' \\' "\n"];
      end
      
    end
  end
  
  latexcode = [latexcode "\n" '\end{' mtype 'matrix}'];
  latexcode = strrep(latexcode," -0 &"," 0 &");
end
