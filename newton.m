## Copyright (C) 2026 entropia64x

## -*- texinfo -*-
## @deftypefn {} {@var{x} =} newton (@var{f}, @var{x0})
##
## @seealso{raiz}
## @end deftypefn

## Author: entropia64x
## Created: 2020-06-23

function [x, iter, err_abs] = newton (funcion, x0, varargin)

  [f, funcion, quiereGrafica, intervalo, quiereTabla, idTabla, max_iter, tol] = inicializacion (funcion,x0,varargin,nargin);

  if ( exist('OCTAVE_VERSION') )
    pkg load symbolic;
  end

  syms z;
  f_symb = f(z);
  deriv_f_symb = diff(f_symb);
  deriv_f = matlabFunction(deriv_f_symb);

  iter = 1;

  while ( iter <= max_iter )

    if ( ~deriv_f(x0) )
      error('Division por cero en  la iteracion %d.\nEscoge otro punto inicial',iter);
    end

    x = x0 - f(x0)/deriv_f(x0);
    err_abs = abs(x - x0);

     if ( quiereGrafica && ~iscomplex(x) )
      intervalo = graficaMetodo(f, iter, x0, x, intervalo);
    end

    if ( quiereTabla )
      fprintf(idTabla,'%4d %0.8f %0.11f\n',iter,x,err_abs)
    end

    if ( err_abs < tol )
      break;
    end

    x0 = x;

    iter++;

  end

  if ( quiereGrafica )
    graficaDetalles(intervalo,iter,x,f,funcion)
  end

  if ( quiereTabla )
    fclose(idTabla);
  end

  if ( iscomplex(x) )
    warning('Raiz par de un numero negativo en la iteracion %d.\n Escoge otra funcion',iter);
  end

  if ( iter > max_iter )
    iter--;
    warning("No se alcanzo la tolerancia %f despues de %d iteraciones\n", tol, iter);
  end

end

function [f, funcion, quiereGrafica, intervalo, quiereTabla, idTabla, max_iter, tol] = inicializacion (funcion,x0,argentvar,nargent)

  if ( nargent < 2 || nargent > 7 )
    print_usage('newton');
  end

  if ( ~ischar(funcion)  && ~is_function_handle(funcion) )
    error("El primer argumento debe ser una funcion incognito o escrita en forma de texto, por ejemplo 'x.^2 - 2'");
  elseif ( ischar(funcion) )
    f = inline(funcion);
  else
    f = funcion;
    funcion = func2str(f);
  end

  if ( ~isnumeric(x0) || ~isscalar(x0) || iscomplex(x0) )
    error('El segundo argumento debe ser escalar real.');
  end

  quiereGrafica = false;
  intervalo = false;
  quiereTabla = false;
  idTabla = false;
  max_iter = 100;
  tol = 1e-6;
  guardomax_iter = false;

  while ( ~isempty(argentvar) )
    if ( tolower(argentvar{1}) == 'g' )
      quiereGrafica = true;
      if ( length(argentvar) < 2 || ~isvector(argentvar{2}) || length(argentvar{2}) ~= 2)
        error('Se necesita el intervalo en formato [a,b]');
      else
        intervalo = argentvar{2};
      end
      argentvar(1) = [];
    elseif ( tolower(argentvar{1}) == 't' )
      quiereTabla = true;
      idTabla = fopen('Tabla.txt','w');
      fprintf(idTabla,'Metodo de punto Newton-Raphson\n\n');
      fprintf(idTabla,'%5s %15s %13s\n','n','x_n','|x_n-x_(n-1)|');
      fprintf(idTabla,'-----------------------------\n');
    elseif ( isnumeric(argentvar{1}) && ~guardomax_iter )
      max_iter = argentvar{1};
      guardomax_iter = true;
    else
      tol = argentvar{1};
    end

    argentvar(1) = [];
  end

  if ( ~isnumeric(max_iter) || max_iter < 1 || max_iter - round(max_iter) )
    error('El numero maximo de iteraciones debe ser un entero positivo');
  end

  if ( ~isnumeric(tol) || tol < 0 || tol > 1 )
    warning('La tolerancia debe ser un real positivo mucho menor que uno');
  end

  if ( quiereGrafica )
    closereq();
    hold on;
  end

end

function intervalo = graficaMetodo(f, iter, x0, x, intervalo )

  intervalo(1) = min([x0 x intervalo]);
  intervalo(2) = max([x0 x intervalo]);

  if ( iter == 1 )
    plot(x0,0,'s;x_0;','MarkerSize',8,'MarkerFaceColor','auto');
  end

  plot([x0 x0], [0 f(x0)],'--','LineWidth',2);
  plot(x,0,'.','MarkerSize',20,'MarkerFaceColor','auto');
  plot([x0 x],[f(x0) 0],':','LineWidth',2);

end

function graficaDetalles(intervalo,iter,x,f,funcion)

  title("Metodo de Newton-Raphson");
  xx = linspace(intervalo(1),intervalo(2),1000);

  yy = 0*xx; y = 0;
  nIter = num2str(iter);
  xn = ['^;x_{' nIter '};'];
  plot(xx,yy,'LineWidth',2);
  plot(x,y,xn,'MarkerSize',8,'MarkerFaceColor','auto');

  funcion = strrep(funcion,"@(x)","");
  funcion = strrep(funcion,".","");
  funcion = strrep(funcion,"*","");
  funcion = strrep(funcion," ^","^");
  funcion = strrep(funcion,"^ ","^");

  plot (xx,f(xx),[";" funcion ";"],'LineWidth',2);

  hold off;

end
