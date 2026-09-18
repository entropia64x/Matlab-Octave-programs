## Copyright (C) 2026 entropia64x

## -*- texinfo -*- 
## @deftypefn {} {@var{x} =} biseccion (@var{f}, @var{a},@var{b})
## @deftypefnx {} {} biseccion (@dots{}, @var{max_iter})
## @deftypefnx {} {} biseccion (@dots{}, @var{max_iter}, @var{tol})
## @deftypefnx {} {} biseccion (@dots{}, 'g', @var{intervalo})
## @deftypefnx {} {} biseccion (@dots{}, 't')
## @deftypefnx {} {[@var{x}, @var{iter}] =} biseccion (@dots{})
## @deftypefnx {} {[@var{x}, @var{iter}, @var{err_abs}] =} biseccion (@dots{})
## 
## Devuelve una aproximacion de la raiz de @var{funcion}
## utilizando el metodo de biseccion. Las funciones
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
## biseccion.txt.
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
## biseccion (@@(x) x.^2 - 2, 1, 2)
## @end example
##
## Si desamos saber la informacion de las iteraciones 
## y el error absoluto escribimos
##
## @example
## [x, iter, err_abs] = biseccion (@@(x) x.^2 - 2, 1, 2)
## @end example
##
## @noindent
## Si no queremos esa informacion y, por el contrario, 
## queremos una grafica y solo 4 iteraciones escribimos
##
## @example
## biseccion (@@(x) x.^2 - 2, 1, 2, 'g', [1 2], 4) 
## @end example
##
## @noindent
## Si necesitamos una tabla con los datos con una tolerancia
## de 0.01 escribimos
##
## @example
## biseccion (@@ x.^2 - 2, 1, 2, 't', 100, 0.01) 
## @end example
## @seealso{raiz}
## @end deftypefn

## Author: entropia64x
## Created: 2020-06-22
## Modified: 2022-01-03

function [x, iter, err_abs] = biseccion (funcion, a, b, varargin);

  [f, funcion, intervalo, idTabla, max_iter, tol] = inicializacion (funcion, a, b, nargin, varargin);

  iter = 1;
  
  while ( iter <= max_iter )
  
    err_abs = abs(b - a)/2;
    x = a + err_abs;
    
    if ( ~isbool(intervalo) && ~iscomplex(x) )
      intervalo = graficaMetodo(f, a, b, x, intervalo, iter);
    end
    
    if ( idTabla )
      fprintf(idTabla,'%5d | %15.8f | %15.8f | %15.8f | %20.12f | %20.12f\n',iter,a,b,x,f(x),err_abs)
    end
    
    if ( err_abs < tol )
      break;
    end
    
    if ( sign(f(a))*sign(f(x)) < 0 )
      b = x;
    else
      a = x;
    end
    
    iter++;
  end
  
  if ( ~isbool(intervalo) )
    graficaDetalles(intervalo,iter,x,f,funcion)
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
  
function [f, funcion, intervalo, idTabla, max_iter, tol] = inicializacion (funcion, a, b, nargent, argentvar)
  
  if ( nargent < 3 || nargent > 8 )
    print_usage('biseccion');
  end
  
  if ( is_function_handle (funcion) )
    f = funcion;
    funcion = func2str (f);
  elseif ( isa (funcion, "inline") )
    f = vectorize (funcion);
    funcion = formula(f);
  elseif ( ischar (funcion) )
    f = vectorize ( inline (funcion) );
    funcion = formula (f);
  else
    error ("El segundo argumento debe ser una funcion incognito o una cadena de texto, por ejemplo @(x) x.^2 - 2");
  end
  
  if ( ~isnumeric(a) || ~isscalar(a) || ~isnumeric(b) || ~isscalar(b) )
    error('El segundo y tercer argumento deben ser escalares reales.');
  end
  
  if ( a == b )
    error('Los puntos iniciales deben ser distintos');
  end
  
  if ( sign(f(a))*sign(f(b)) > 0 )
    error('Se debe cumplir f(a)f(b) < 0.\nEscoge otros puntos iniciales');
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
      idTabla = fopen('biseccion.txt','w');
      fprintf(idTabla,'%5s | %15s | %15s | %15s | %20s | %20s\n','n','a_n','b_n','x_n','f(x_n)','|x_n-x_(n-1)|');
      fprintf(idTabla,'---------------------------------------------------------------------------------------------------------\n');
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

function intervalo = graficaMetodo(f, a, b, x, intervalo, iter)
  
  intervalo(1) = min([a b x intervalo]);
  intervalo(2) = max([a b x intervalo]);
  
  if ( iter == 1 )
    plot(a,0,'s;a;','MarkerSize',8,'MarkerFaceColor','auto');
    plot(b,0,'s;b;','MarkerSize',8,'MarkerFaceColor','auto');
    legend("off");
    plot([a a], [0 f(a)],'--','LineWidth',2);
    plot([b b], [0 f(b)],'--','LineWidth',2);
  end
  
  legend("off")
  plot(x,0,'.','MarkerSize',20,'MarkerFaceColor','auto');
  plot([x x], [0 f(x)],'--','LineWidth',2);
  
end

function graficaDetalles(intervalo,iter,x,f,funcion)

  title("Metodo de bisección");
  xx = linspace(intervalo(1),intervalo(2),1000);
    
  yy = 0*xx; y = 0;
  nIter = num2str(iter);
  xn = ['^;x_{' nIter '};'];
  plot(xx,yy,'LineWidth',2);
  plot(x,y,xn,'MarkerSize',8,'MarkerFaceColor','auto');
    
  funcion = strrep(funcion,"@(x) ","");
  funcion = strrep(funcion,".","");
  funcion = strrep(funcion," * ","");
  funcion = strrep(funcion," ^ ","^");
  funcion = strrep(funcion," / ","/");
  funcion = strrep(funcion,"*","");
    
  plot (xx,f(xx),[";" funcion ";"],'LineWidth',2);
    
  hold off;
end
