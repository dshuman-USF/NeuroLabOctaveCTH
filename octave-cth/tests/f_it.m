function val =f_it(u, x, y)
% test function
   PoisLS = @(u, x, y) norm(p_ois(u,x)-y) ;
  val = u .^x * exp(-u) ./ gamma(x+1);
end


