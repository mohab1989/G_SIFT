clc;
clear;
close all;
r = 100;
test1= 1:5;
test2=[r/16 r/8 r/4 r/2 r];
o= 1:r;
x = 1:r;
x=((log(x))+log(test2(1)));
y= (x./log(test2(1)));

plot(x,y);
hold;
plot(log(test2),test1,'*');
xlabel('Log R');
ylabel('Bins');

plot(log(test2),test1);