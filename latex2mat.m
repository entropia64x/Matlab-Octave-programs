## Copyright (C) 2019-2026 entropia64x

## -*- texinfo -*-
##
## @deftypefn {} {} latex2mat (@var{latexcode})
##
## Returns the matrix of a LaTeX code string.
##
## It accepts from the beginning of the environment
## \begin@{pmatrix@} until the end \end@{pmatrix@},
## or just the middle part.
##
## @example
## @group
## c = '1 & 2 & 3 \\ 4 & 5 & 6 \\ 7 & 8 & 9';
## latex2mat(c)
## @result{}
##   1   2   3
##   4   5   6
##   7   8   9
## @end group
## @end example
##
## @example
## @group
## c = '\begin@{pmatrix@} 1 & 2 & 3 \\ 4 & 5 & 6 \\ 7 & 8 & 9 \end@{pmatrix@}';
## latex2mat(c)
## @result{}
##   1   2   3
##   4   5   6
##   7   8   9
## @end group
## @end example
##
## It accepts the environments matrix, pmatrix, bmatrix,
## vmatrix, Bmatrix, Vmatrix.
##
## @seealso{mat2latex, mat2system}
## @end defmtypefn

## author: entropia64x

function matrix = latex2mat(code)

  if ( nargin ~= 1 )
    print_usage();
  elseif ( ~ischar(code) )
    error('The code must be a string.');
  end
  
  matrix = strrep(code,'\begin{pmatrix}','');
  matrix = strrep(matrix,'\begin{bmatrix}','');
  matrix = strrep(matrix,'\begin{vmatrix}','');
  matrix = strrep(matrix,'\begin{Bmatrix}','');
  matrix = strrep(matrix,'\begin{Vmatrix}','');
  matrix = strrep(matrix,'\begin{matrix}','');
  
  matrix = strrep(matrix,'\end{pmatrix}','');
  matrix = strrep(matrix,'\end{bmatrix}','');
  matrix = strrep(matrix,'\end{vmatrix}','');
  matrix = strrep(matrix,'\end{Bmatrix}','');
  matrix = strrep(matrix,'\end{Vmatrix}','');
  matrix = strrep(matrix,'\end{matrix}','');
  
  matrix = strrep(matrix,'&',',');
  matrix = strrep(matrix,'\\',';');
  matrix = strrep(matrix,' -0 ',' 0 ');

  matrix = ['[' matrix ']'];
  matrix = str2num(matrix);

  if ( isempty(matrix) )
    error('The LaTeX code does not represent a valid numeric matrix.');
  end
endfunction
