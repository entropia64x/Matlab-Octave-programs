function matriz = latex2mat(codigo)
  matriz = strrep(codigo,'\begin{pmatrix}','[');
  matriz = strrep(matriz,' & ',' ');
  matriz = strrep(matriz,'\\',';');
  matriz = strrep(matriz,'\end{pmatrix}',']');
  matriz = strrep(matriz,'-0','0');
  matriz = str2num(matriz);
endfunction
