function kernel = GaussianDerivative(kernelSize,sigma,withRespectTo)
if mod(kernelSize,2) == 0
    disp('kernelSize should be odd');
    return;
end
kernel= zeros(kernelSize,kernelSize);
order =size(withRespectTo,2);
halfKernelSize = (kernelSize-1)/2;

switch order
   case 1
      for x = -halfKernelSize : halfKernelSize
          for y = -halfKernelSize : halfKernelSize
              xOrY =1;
              if(withRespectTo(1) == 'x' || withRespectTo(1) == 'X')
                 xOrY=x;
              else
                 xOrY=y;
              end               
              kernel(x+halfKernelSize+1,y+halfKernelSize+1)= (-xOrY/(2*pi*(sigma^4)))*(exp(-((x^2)+(y^2))/2*(sigma^2)));
          end
      end
   case 2
       if (withRespectTo(1)== 'x' && withRespectTo(2)== 'y' ||withRespectTo(2)== 'x' && withRespectTo(1)== 'y')
          for x = -halfKernelSize : halfKernelSize
            for y = -halfKernelSize : halfKernelSize
                kernel(y+halfKernelSize+1,x+halfKernelSize+1)= ((x*y)/((2*pi)*(sigma^6)))*(exp(-((x^2)+(y^2))/(2*(sigma^2))));
            end
           end
       else
            for x = -halfKernelSize : halfKernelSize
                for y = -halfKernelSize : halfKernelSize
                    xOrY =1;
                    if(withRespectTo(1) == 'x' || withRespectTo(1) == 'X')
                        xOrY=x;
                    else
                        xOrY=y;
                    end
                    kernel(y+halfKernelSize+1,x+halfKernelSize+1)=(-1+((xOrY^2)/(sigma^2)))*((exp(-(x^2+y^2)/(2*(sigma^2))))/(2*pi*(sigma^4)));
                end
            end     
       end
   otherwise
      disp('withRespectTo size must be 1 or 2 for first and second derivatives respectively');
      return;
end

end