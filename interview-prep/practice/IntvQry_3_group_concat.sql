/*

-- imput 

Apple
Banana
Avacadro
Blueberries
Orange
Mango


Ouput
A, Appple,Avacoadro , 
B, Banana,blueberries, 
O,Orange,
M, Mango

*/

CREATE Table fruits (fruit_name varchar(20));

INSERT into fruits values ("Apple"),("Banana"),("Avacadro"),("Blueberries"),("Orange"),("Mango");

select * FROM fruits ;

select LEFT(fruit_name,1 ),GROUP_concat(fruit_name)  from fruits group by LEFT(fruit_name,1 );