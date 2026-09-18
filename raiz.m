## Copyright (C) 2019-2026 entropia64x

## -*- texinfo -*-
##
## @deftypefn  {} {} raiz (@var{método}, @var{funcion}, @var{x0})
## @deftypefnx {} {} raiz (@var{método}, @var{funcion}, @var{x0}, @var{x1})
## @deftypefnx {} {} raiz (@dots{}, @var{max_iter})
## @deftypefnx {} {} raiz (@dots{}, @var{max_iter}, @var{tol})
## @deftypefnx {} {} raiz (@dots{}, 'g', @var{intervalo})
## @deftypefnx {} {} raiz (@dots{}, 't')
## @deftypefnx {} {[@var{x}, @var{iter}] =} raiz (@dots{})
## @deftypefnx {} {[@var{x}, @var{iter}, @var{err_abs}] =} raiz (@dots{})
##
## Devuelve una aproximación de la raíz de @var{funcion}
## utilizando el @var{método} especificado. Las funciones
## tienen que ir en formato de texto o como funciones
## incógnito y de forma vectorial
## si se desea hacer graficas.
##
## Los distintos métodos que soporta se enlistan a continuación.
## @table @asis
## @item Métodos:
##
## @multitable @columnfractions 0.06 0.94
## @item @samp{b}  @tab Método de bisección.
## @item @samp{p}  @tab Método de punto fijo.
## @item @samp{a}  @tab Método de Aitken.
## @item @samp{n}  @tab Método de Newton-Raphson.
## @item @samp{s}  @tab Método de la secante.
## @item @samp{f}  @tab Método de la falsa posicion.
## @end multitable
## @end table
##
## Los métodos de punto fijo, Aitken  y de Newton-Raphson
## solo necesitan un punto inicial x0.
## Los otros necesitan de dos puntos iniciales: x0 y x1.
##
## Si se desea una gráfica, basta con agregar @qcode{'g'} y
## a la derecha un intervalo en formato de vector.
## Por ejemplo @var{intervalo} = [1 2]. El intervalo es
## para especificar la mínima longitud del 'eje x',
## pero esta longitud se agranda si el método lo requiere.
## El 'eje y' se ajusta solo.
##
## Si se desea una tabla, se debe agregar @qcode{'t'}.
## La tabla se guarda en un archivo de texto llamado
## raiz.txt.
##
## @var{max_iter} es el número máximo de iteraciones que
## se desean hacer. Por defecto se toma @var{max_iter} = 100.
##
## @var{tol} es la tolerancia de la aproximacion del
## error absoluto. Por defecto se toma @var{tol} = 1e-6.
## La formula es |x_n - x_{n-1}|. Si se desea
## especificar la tolerancia, primero hay que poner el
## número máximo de iteraciones.
##
## Algunos ejemplos de su uso son los siguientes:
##
## @noindent
## Si se desea encontrar una raíz entre 1 y 2 de la función
## x^2 - 2 por el método de bisección escribimos
##
## @example
## raiz('b',@@(x) x.^2 - 2,1,2)
## @end example
##
## Si desamos saber la información de las iteraciones
## y el error absoluto escribimos
##
## @example
## [x, iter, err_abs] = raiz ('b', @@(x) x.^2 - 2, 1, 2)
## @end example
##
## @noindent
## Si no queremos esa información y por el contrario
## queremos una gráfica y solo 4 iteraciones escribimos
##
## @example
## raiz ('b', @@(x) x.^2 - 2,1,2), 'g', [1 2], 4)
## @end example
##
## @noindent
## Si necesitamos una tabla con los datos con una tolerancia
## de 0.01 escribimos
##
## @example
## raiz ('b', @@ x.^2 - 2, 1, 2, 't', 100, 0.01)
## @end example
##
## @seealso{biseccion, newton, secante, falsaposicion, aitken}
## @end deftypefn

## Author: entropia64x <entropia64x@gmail.com>
## Created: 2020-06-22
## Modified: 2022-01-03

function [x, iter, err_abs] = raiz (metodo, funcion, x0, varargin)

  [f, nombrefn, x1, intervalo, idTabla, max_iter, tol, titulo] = inicializacion (metodo, funcion, x0, nargin, varargin);

  [x, iter, err_abs, intervalo] = realizaMetodo (metodo, f, x0, x1, max_iter, intervalo, idTabla, tol);

  if ( ~isbool(intervalo) )
    graficaDetalles(metodo, titulo, intervalo, iter, x, f, nombrefn);
  end

  if ( idTabla )
    fclose(idTabla);
  end

  if ( iscomplex(x) )
    warning('Raiz par de un numero negativo en la iteracion %d.\n Escoge otra funcion',iter);
  end

  if ( iter >= max_iter )
    warning("No se alcanzo la tolerancia %f despues de %d iteraciones\n", tol, iter);
  end

  if ( metodo == 's' || metodo == 'f' )
    iter--;
  end

end

function [f, nombrefn, x1, intervalo, idTabla, max_iter, tol, titulo] = inicializacion ( metodo, funcion, x0, nargent, argentvar)
  if ( nargin < 3 || nargent > 9 )
    print_usage('raiz');
  end

  metodo = tolower(metodo);

  switch (metodo)
    case {'b','s','f'}
      mindat = 4;
    case {'a','p','n'}
      mindat = 3;
      x1 = x0;
    otherwise
      error("Ese metodo no existe\n'b': Biseccion.\n'p': Punto fijo.\n'a': Aitken.\n'n' : Netwton-Rapson.\n's': Secante.\n'f': Falsa posicion.");
  end

  if ( nargent < mindat || nargent > mindat + 5 )
    warning('Necesitas al menos %d argumentos', mindat);
    print_usage('raiz');
  end

  if ( is_function_handle (funcion) )
    nombrefn = func2str (funcion);
  elseif ( isa (funcion, "inline") )
    funcion = vectorize (funcion);
    nombrefn = formula(funcion);
  elseif ( ischar (funcion) )
    funcion = vectorize ( inline (funcion) );
    nombrefn = formula (funcion);
  else
    error ("El segundo argumento debe ser una funcion incognito, o una cadena de texto, por ejemplo @(x) x.^2 - 2");
  end

    if (metodo == 'a')
    f = @(x) (x.*funcion(funcion(x))-funcion(x).^2)./(funcion(funcion(x))-2*funcion(x)+x);
    nombrefn = '\phi(x)';
  else
    f = funcion;
  end

  if ( ~isnumeric(x0) || ~isscalar(x0) || iscomplex(x0) )
    error('El tercer argumento debe ser un escalar real');
  end

  if ( mindat == 4 )
    x1 = argentvar{1};
    argentvar(1) = [];
    if ( ~isnumeric(x1) || ~isscalar(x1) || iscomplex(x1) )
      error('El cuarto argumento debe ser un escalar real');
    end
    if ( x0 == x1 )
      error('Los puntos iniciales deben ser distintos');
    end
  end

  intervalo = false;
  idTabla = false;
  max_iter = 100;
  tol = 1e-6;
  guardomax_iter = false;

  switch ( metodo )
    case 'b'
      titulo = 'Método de bisección';
    case 'p'
      titulo = 'Método de punto fijo';
    case 'a'
      titulo = 'Método de Aitken';
    case 'n'
      titulo = 'Método de Newton-Raphson';
    case 's'
      titulo = 'Método de la secante';
    case 'f'
      titulo = 'Método de la falsa posición';
  end

  while ( ~isempty(argentvar) )
    if ( tolower(argentvar{1}) == 'g' )
      if ( length(argentvar) < 2 || ~isvector(argentvar{2}) || length(argentvar{2}) ~= 2)
        error('Se necesita el intervalo en formato [a,b]');
      else
        intervalo = argentvar{2};
      end
      argentvar(1) = [];
    elseif ( tolower(argentvar{1}) == 't' )
      idTabla = fopen('raiz.txt','w');
      fprintf(idTabla,'%s\n\n',titulo);
      switch ( metodo )
        case 'b'
          fprintf(idTabla,'%5s | %15s | %15s | %15s | %20s | %20s\n','n','a_n','b_n','x_n','f(x_n)','|x_n-x_(n-1)|');
          fprintf(idTabla,'---------------------------------------------------------------------------------------------------------\n');
        case {'s','f'}
          fprintf(idTabla,'%5s | %15s | %15s | %15s | %20s | %20s\n','n','x_(n-2)','x_(n-1)','x_n','f(x_n)','|x_n-x_(n-1)|');
          fprintf(idTabla,'---------------------------------------------------------------------------------------------------------\n');
        otherwise
          fprintf(idTabla,'%5s | %15s | %20s | %20s\n','n','x_n','f(x_n)','|x_n-x_(n-1)|');
          fprintf(idTabla,'---------------------------------------------------------------------\n');
          fprintf(idTabla,'%5d | %15.8f | %20.12f | \n',0,x0,f(x0));
      end
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

function  [x, iter, err_abs, intervalo] = realizaMetodo (metodo, f, x0, x1, max_iter, intervalo, idTabla, tol)

  iter = 0;

  switch(metodo)
    case 'b'
      if ( sign(f(x0))*sign(f(x1)) > 0 )
        error('Se debe cumplir f(a)f(b) < 0.\nEscoge otros puntos iniciales');
      end
    case 'n'
      if ( exist('OCTAVE_VERSION') )
        pkg load symbolic;
      end
      syms z;
      f_symb = f(z);
      deriv_f_symb = diff(f_symb);
      deriv_f = matlabFunction(deriv_f_symb);
    case {'s','f'}
      iter++;
      max_iter++;
  end

  while ( iter < max_iter )

    iter++;

    switch ( metodo )
      case 'b'
        x = x0 + abs(x1 - x0)/2;
      case {'p','a'}
        x = f(x0);
        x1 = x0;
      case 'n'
        if ( ~deriv_f(x0) )
          error('Division por cero en  la iteracion %d.\nEscoge otro punto inicial',iter);
        end
        x = x0 - f(x0)/deriv_f(x0);
        x1 = x0;
      otherwise
        x = x1 - f(x1)*(x1 - x0)/(f(x1) - f(x0));
    end

    d = 1e30;
    err_abs = abs(d*x - d*x1)/d;

    if ( ~isbool(intervalo) && ~iscomplex(x) )
      intervalo = graficaMetodo(metodo, f, iter, x0, x1, x, intervalo);
    end

    if ( idTabla )
      switch(metodo)
        case {'b','s','f'}
          fprintf(idTabla,'%5d | %15.8f | %15.8f | %15.8f | %20.12f | %20.12f\n',iter,x0,x1,x,f(x),err_abs);
        otherwise
          fprintf(idTabla,'%5d | %15.8f | %20.12f | %20.12f\n',iter,x,f(x),err_abs);
        end
    end

    if ( err_abs < tol )
      break;
    end

    switch ( metodo )
      case 'b'
        if ( sign(f(x0))*sign(f(x)) < 0 )
          x1 = x;
        else
          x0 = x;
        end
      case {'p','a','n'}
        x0 = x;
      case {'s','f'}
        if ( metodo == 's' || sign(f(x))*sign(f(x1)) < 0)
          x0 = x1;
        end
        x1 = x;
    end
  end

end

function intervalo = graficaMetodo(metodo, f, iter, x0, x1, x, intervalo)

  intervalo(1) = min([x0 x1 x intervalo]);
  intervalo(2) = max([x0 x1 x intervalo]);

  c = ( metodo == 'p' || metodo == 'a');
  y = c*x;
  y0 = c*x0;
  y1 = c*x1;

  if ( iter == 1 )
    switch(metodo)
      case 'b'
        plot(x0,y0,'s;a;','MarkerSize',8,'MarkerFaceColor','auto');
        plot(x1,y1,'s;b;','MarkerSize',8,'MarkerFaceColor','auto');
        legend("off")
        plot([x0 x0], [y0 f(x0)],'--','LineWidth',2);
        plot([x1 x1], [y1 f(x1)],'--','LineWidth',2);
      case {'p','a','n'}
        plot(x0,y0,'s;x_0;','MarkerSize',8,'MarkerFaceColor','auto');
    end
  elseif ( iter == 2 && (metodo == 's' || metodo == 'f' ) )
    plot(x0,y0,'s;x_0;','MarkerSize',8,'MarkerFaceColor','auto');
    plot(x1,y1,'s;x_1;','MarkerSize',8,'MarkerFaceColor','auto');
    legend("off")
    plot([x0 x0], [y0 f(x0)],'--','LineWidth',2);
  end

  legend("off")
  if( metodo ~= 'b' )
    plot([x1 x1], [y1 f(x1)],'--','LineWidth',2);
  else
    x1 = x0 = x;
  end
  plot(x,y,'.','MarkerSize',18,'MarkerFaceColor','auto');
  plot([x0 x1 x],[f(x0) f(x1) c*f(x0)],':','LineWidth',2);

end

function graficaDetalles(metodo, titulo, intervalo, iter, x, f, nombrefn);

  title(titulo);
  xx = linspace(intervalo(1),intervalo(2),1000);
  c = ( metodo == 'p' || metodo == 'a' );
  yy = c*xx;
  y = c*x;

  plot(xx,yy,'LineWidth',2);
  nIter = num2str(iter);
  xn = ['^;x_{' nIter '};'];
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
