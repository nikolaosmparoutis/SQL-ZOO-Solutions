
SELECT within SELECT Tutorial

1.
List each country name where the population is larger than that of 'Russia'.

SELECT name FROM world
  WHERE population >
     (SELECT population FROM world
      WHERE name='Russia')
Submit SQLRestore default
result


2.
Show the countries in Europe with a per capita GDP greater than 'United Kingdom'.


select name
from world
where gdp/population > (select gdp/population from world where name = "United Kingdom") and world.continent = "Europe"

Submit SQLRestore default
result


3.
List the name and continent of countries in the continents containing either Argentina or Australia. Order by name of the country.

select name,continent
from world
where continent in (
select continent
from world 
where name = "Argentina" or name = "Australia"
)
order by name



4.
Which country has a population that is more than Canada but less than Poland? Show the name and the population.

select name, population
from world w1
where w1.population > (select population from world where name = "Canada") and w1.population < (select population from world where name = "Poland")
 

5.
Germany (population 80 million) has the largest population of the countries in Europe. Austria (population 8.5 million) has 11% of the population of Germany.
Show the name and the population of each country in Europe. Show the population as a percentage of the population of Germany.

select name, CONCAT(population/(select population from world where name = "Germany"),"%") percentage
from world 
where continent  = "Europe"


6.
Which countries have a GDP greater than every country in Europe? [Give the name only.] (Some countries may have NULL gdp values)

select name from world where 
gdp > ALL (
select gdp
from world w2
where w2.continent = "Europe" and w2.gdp > 0)

We can refer to values in the outer SELECT within the inner SELECT. We can name the tables so that we can tell the difference between the inner and outer versions.


7.
Find the largest country (by area) in each continent, show the continent, the name and the area:

 select w2.continent,w2.name
 from world w2
 group by w2.continent 
 order by w2.continent
 

Using correlated subqueries

8.
List each continent and the name of the country that comes first alphabetically.


 select w2.continent,w2.name
 from world w2
 group by w2.continent 
 order by w2.continent
 
Difficult Questions That Utilize Techniques Not Covered In Prior Sections
9.
Find the continents where all countries have a population <= 25000000. Then find the names of the countries associated with these continents. Show name, continent and population.

select w1.continent
from world w1
where  w1.continent 
except  (
select w2.continent
from world w2 
where w2.population > 25000000)

10.
Some countries have populations more than three times that of any of their neighbours (in the same continent). Give the countries and continents.

SELECT x.name, x.continent
FROM world AS x
WHERE x.population/3 > ALL (
  SELECT y.population
  FROM world AS y
  WHERE x.continent = y.continent
  AND x.name != y.name);

