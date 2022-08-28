# Values to formula generator

**purpose:** Generate a formula for an array of values where f(index+1) is equal to the specified value

### compilation

Set up dependencies -> [stdasm](https://github.com/LACHBAC5/stdasm).

Compile main.s -> make stdasm=*path-to-stdasm*

### input

Choose a formula like -x^2+x^1, where x is equal to the number of the file line

and write it's output after each line.

There mustn't be spacing between values.

The column of values must start from line 1.

Integers like 1,2,3 must too be written like floats 1.0,2.0,3.0.

### output

The output is structured as follows:

pow(x, y)\*z1

pow(x, y-1)\*z2

pow(x, y-2)\*z3

pow(x, y-3)\*z4

pow(x, y-4)\*z5

...until the exponent reaches 0

Where "x" is just a placeholder for whichever index+1 from the array,

"y" is the biggest exponent in the formula and constant,

"z\*" is a calculated constant.

To calculate the result after a "x" is chosen just substitute it in each line and add the result to the total 

e.g. pow(x, 2)\*1.5+pow(x, 1)\*1+pow(x, 0)\*(-0.5)

note: **pow(x, 0)** is always equal to **1**

### special cases

Binary representation of decimal floating point values is sometimes wrong.

So it is possible to get output like the following:

-0.000000\*pow(x, 7)

0.000000\*pow(x, 6)

-0.000004\*pow(x, 5)

0.000027\*pow(x, 4)

-0.000100\*pow(x, 3)

1.000208\*pow(x, 2)

1.099781\*pow(x, 1)

0.000088\*pow(x, 0)

Where the sequence of numbers is calculated using:

pow(x, 2) + pow(x, 1)\***1.1**