## Copyright (C) 2021 entropia64x

## -*- texinfo -*- 
## @deftypefn {} {@var{x} =} aitken (@var{f}, @var{x0})
## @deftypefnx {} {} aitken (@dots{}, @var{max_iter})
## @deftypefnx {} {} aitken (@dots{}, @var{max_iter}, @var{tol})
## @deftypefnx {} {} aitken (@dots{}, 'g', @var{intervalo})
## @deftypefnx {} {} aitken (@dots{}, 't')
## @deftypefnx {} {[@var{x}, @var{iter}] =} aitken (@dots{})
## @deftypefnx {} {[@var{x}, @var{iter}, @var{err_abs}] =} aitken (@dots{})
## 
## Devuelve una aproximacion de la raiz de @var{funcion}
## utilizando el metodo de punto fijo. Las funciones
## tienen que ir en formato de texto o como funciones
## incognito y de forma vectorial
## si se desea hacer graficas.
## 
## Si se desea una grafica, basta con agregar @qcode{'g'} y 
## a la derecha un intervalo en formato de vector.
## Por ejemplo @var{intervalo} = [1 2]. El intervalo es
## para especificar la minima longitud del 'eje x',
## pero esta longitud se agranda si el metodo lo requiere.
## El 'eje y' se ajusta solo.
##
## Si se desea una tabla, se debe agregar @qcode{'t'}.
## La tabla se guarda en un archivo de texto llamado
## aitken.txt.
##
## @var{max_iter} es el numero maximo de iteraciones que
## se desean hacer. Por defecto se toma @var{max_iter} = 100.
##
## @var{tol} es la tolerancia de la aproximacion del
## error absoluto. La formula es |x_n - x_(n-1)|.
## Por defecto se toma @var{tol} = 1e-6. Si se quiere
## especificar la tolerancia primero hay que poner el
## numero maximo de iteraciones.
## 
## Algunos ejemplos de su uso son los siguientes:
## 
## @noindent
## Si se desea encontrar una raiz entre 1 y 2 de la funcion
## x^2 - 2 por el metodo de biseccion, escribimos
## 
## @example
## aitken (@@(x) x.^2 - 2, 1, 2)
## @end example
##
## Si desamos saber la informacion de las iteraciones 
## y el error absoluto escribimos
##
## @example
## [x, iter, err_abs] = aitken (@@(x) x.^2 - 2, 1, 2)
## @end example
##
## @noindent
## Si no queremos esa informacion y, por el contrario, 
## queremos una grafica y solo 4 iteraciones escribimos
##
## @example
## raiz ('b', @@(x) x.^2 - 2, 1, 2), 'g', [1 2], 4) 
## @end example
##
## @seealso{raiz, biseccion}
## @end deftypefn

## Author: entropia64x
## Created: 2022-01-03

function [x, iter, err_abs] = aitken (funcion, x0, varargin)
  
  [g, nombrefn, intervalo, idTabla, max_iter, tol] = inicializacion (funcion, x0, varargin, nargin);
  
  iter = 1;
  phi = @(x) (x.*g(g(x))-g(x).^2)./(g(g(x))-2*g(x)+x);
  
  while ( iter <= max_iter )
    x = phi(x0);
    err_abs = abs(x - x0);
    
    if ( ~isbool(intervalo) && ~iscomplex(x) )
      intervalo = graficaMetodo (phi, iter, x0, x, intervalo);
    end
    
    if ( idTabla )
      fprintf (idTabla,'%5d | %15.8f | %20.12f | %20.12f\n',iter, x, phi(x), err_abs);
    end
    
    if ( err_abs < tol )
      break;
    end
  
    x0 = x;
    iter++;
  end
  
  if ( ~isbool(intervalo) )
    graficaDetalles (intervalo, iter, x, phi, nombrefn)
  end
  
  if ( idTabla )
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

function [phi, nombrefn, intervalo, idTabla, max_iter, tol] = inicializacion (funcion, x0, argentvar, nargent)
  
  if ( nargent < 2 || nargent > 7 )
    print_usage('aitken');
  end
  
  if ( is_function_handle (funcion) )
    phi = funcion;
  elseif ( isa (funcion, "inline") )
    phi = vectorize (funcion);
  elseif ( ischar (funcion) )
    phi = vectorize ( inline (funcion) );
  else
    error ("El segundo argumento debe ser una funcion incognito o una cadena de texto, por ejemplo @(x) x.^2 - 2");
  end
  
  nombrefn = '\phi(x)';
  
  if ( ~isnumeric(x0) || ~isscalar(x0) || iscomplex(x0) )
    error('El segundo argumento debe ser escalar real.');
  end
  
  intervalo = false;
  idTabla = false;
  max_iter = 100;
  tol = 1e-6;
  guardomax_iter = false;
  
  while ( ~isempty(argentvar) )
    if ( tolower(argentvar{1}) == 'g' )
      if ( length(argentvar) < 2 || ~isvector(argentvar{2}) || length(argentvar{2}) ~= 2)
        error('Se necesita el intervalo en formato [a,b]');
      else
        intervalo = argentvar{2};
      end
      argentvar(1) = [];
    elseif ( tolower(argentvar{1}) == 't' )
      idTabla = fopen('aitken.txt','w');
      fprintf(idTabla,'Metodo de Aitken\n\n');
      fprintf(idTabla,'%5s | %15s | %20s | %20s\n','n','x_n','phi(x_n)','|x_n-x_(n-1)|');
      fprintf(idTabla,'---------------------------------------------------------------------\n');
      fprintf(idTabla,'%5d | %15.8f | %20.12f | \n',0,x0,phi(x0));
    elseif ( isnumeric(argentvar{1}) && ~guardomax_iter )
      max_iter = argentvar{1};
      guardomax_iter = true;
    else
      tol = argentvar{1};
    end
    
    argentvar(1) = [];
  end
  
  if ( ~isnumeric(max_iter) || ~isscalar(max_iter) || iscomplex(max_iter) || max_iter < 1 || max_iter - round(max_iter) )
    error('El numero maximo de iteraciones debe ser un entero positivo');
  end
  
  if ( ~isnumeric(tol) || ~isscalar(tol) || iscomplex(tol) || tol < 0 || tol > 1 )
    warning('La tolerancia debe ser un real positivo mucho menor que uno');
  end

  if ( ~isbool(intervalo) )
    closereq();
    hold on;
  end

end

function intervalo = graficaMetodo(f, iter, x0, x, intervalo )
  
  intervalo(1) = min([x0 x intervalo]);
  intervalo(2) = max([x0 x intervalo]);
  
  if ( iter == 1 )
    plot(x0,x0,'s;x_0;','MarkerSize',8,'MarkerFaceColor','auto');
  end
  
  legend("off");
  plot([x0 x0], [x0 f(x0)],'--','LineWidth',2);
  plot(x,x,'.','MarkerSize',18,'MarkerFaceColor','auto');
  plot([x0 x],[f(x0) f(x0)],':','LineWidth',2);
  
end

function graficaDetalles(intervalo, iter, x, f, nombrefn)

  title("Metodo de Aitken");
  xx = linspace(intervalo(1),intervalo(2),1000);
    
  yy = xx; y = x;
  nIter = num2str(iter);
  xn = ['^;x_{' nIter '};'];
  plot(xx,yy,'LineWidth',2);
  plot(x,y,xn,'MarkerSize',8,'MarkerFaceColor','auto');
    
  nombrefn = strrep(nombrefn,"@(x) ","");
  nombrefn = strrep(nombrefn,".","");
  nombrefn = strrep(nombrefn," * ","");
  nombrefn = strrep(nombrefn," / ","/");
  nombrefn = strrep(nombrefn," ^ ","^");
  nombrefn = strrep(nombrefn,"*","");
    
  plot (xx,f(xx),[";" nombrefn ";"],'LineWidth',2);
    
  hold off;
  
end
