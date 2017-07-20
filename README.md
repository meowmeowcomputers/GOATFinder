# GOATFinder
Not goat as in the animal that eats tin cans. GOAT as in Greatest Of All Time. 
The purpose of this app is to figure out, using various weights and measures, who the greatest baseball players of all time are, and the take it a step further and answer the question: who are the greatest baseball players of <i>any</i> given time period?

The data was sourced from Sean Lahman's <a href="http://www.seanlahman.com/baseball-archive/statistics/">baseball database</a>, and extends to 2016. This project was an exercise and study in SQL

Inital MVP: Create a slider that queries for a user-given year window and returns a roster of the greatest baseball players by their primary position through various criteria: batting stats (On Base Plus Slugging) for position players, Wins then ERA/WHIP for starting pitchers, and Saves then ERA/WHIP for bullpen pitchers.

Stretch goals: 
<ul>
  <li>Allow for user-defined weighting of various other stats, such as homeruns, strikeouts, etc.</li> *Done!
  <li>Allow for querying by a given team/division/year</li> *Done, except for league/division, which will require far more research
  <li>Refactor in React to allow for dynamic return of data</li>
  <li>Fork off to a dashboard in Mongo or another noSQL database to learn its dynamics</li>
</ul>

Challenges:
 <ul>
  <li>Finding a comprehensive dataset online</li>
  <li>Working with MySQL after being so comfortable with Postgres</li>
  <li>Creating an aggregate query. The dataset was raw and there were all sorts of quirks to the database.</li>
  <ul>
  <li>Datatypes were not as expected (varchar on an integer-only column)</li>
  <li>Teamid was not what I thought it was, and there's a key called franchid that I had to research what the difference was</li>
  <li>
   </ul>
   <li>Making the query more efficient. Initial query was 4 seconds long. I used combination of indexes and materialized views, as the data was static. I also broke out some of the queries in to separate queries to reduce the number of joins. Aggregator query is now .3 seconds.</li>
   
</ul>
