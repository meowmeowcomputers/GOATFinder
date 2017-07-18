'use strict';

const express = require('express');
const app = express();
const body_parser = require('body-parser');
const session = require('express-session');

/*************** Database ***************/
const promise = require('bluebird');
const pgp = require('pg-promise')({
  promiseLib: promise,
});
//Development database settings
const db = pgp(process.env.DATABASE_URL||{
  host: 'localhost',
  port: 5432,
  database: 'baseball',
  user: 'postgres',
});
/*********** App Configuration **************/
var hbs = require('hbs');
app.set('view engine', 'hbs');
hbs.registerPartials('views/partials');

app.use('/static', express.static('static'));
app.use(body_parser.urlencoded({extended: false}));
app.use(body_parser.json());


let PORT = process.env.PORT || 9000;
app.listen(PORT, function () {
  console.log('Listening on port ' + PORT);

});

// // NOTE: Sample query: Un-Comment to check connection to database
// db.query("SELECT * FROM baseball.batting LIMIT 100")
//   .then(function(results) {
//     results.forEach(function(row) {
//         console.log(row.name, row.atmosphere, row.parking, row.busy);
//     });
//     // return db.one("SELECT * FROM restaurant WHERE name='tout suit'");
//   })


app.get('/', function (req, resp) {
  resp.render('index.hbs');
});

app.get('/submit', function (req, resp) {
  resp.render('index.hbs');
});

app.post('/submit', function (req, resp) {
  // console.log('Minimum year: '+req.body.min_slider)
  // console.log('Maximum year: '+req.body.max_slider)
  var minYear = req.body.min_slider;
  var maxYear = req.body.max_slider;
  var allResults = []
  //Outfielder search
  db.query(`SELECT fullnames.namefirst, fullnames.namelast, CAST(avghr.ops as DECIMAL(4,3)), position.pos, avghr.abavg FROM batter_names as fullnames JOIN (SELECT avg(baseball.batting.ops) as ops, baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} GROUP BY idavg) as avghr ON fullnames.idall = avghr.idavg JOIN ( SELECT poslist.playerid, poslist.pos FROM position_occurence AS poslist LEFT JOIN position_occurence AS primarypos ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence WHERE primarypos.playerid IS NULL) as position ON avghr.idavg = position.playerid WHERE avghr.abavg > 350 AND position.pos = 'OF' GROUP BY fullnames.namefirst, fullnames.namelast, avghr.ops, position.pos, avghr.abavg ORDER BY ops DESC LIMIT 6;`)
    .then(function(results) {
      allResults.push(results)
    })
  //First Base
    .then(function() {
      return db.query(`SELECT fullnames.namefirst, fullnames.namelast, CAST(avghr.ops as DECIMAL(4,3)), position.pos, avghr.abavg FROM batter_names as fullnames JOIN (SELECT avg(baseball.batting.ops) as ops, baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} GROUP BY idavg) as avghr ON fullnames.idall = avghr.idavg JOIN ( SELECT poslist.playerid, poslist.pos FROM position_occurence AS poslist LEFT JOIN position_occurence AS primarypos ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence WHERE primarypos.playerid IS NULL) as position ON avghr.idavg = position.playerid WHERE avghr.abavg > 350 AND position.pos = '1B' GROUP BY fullnames.namefirst, fullnames.namelast, avghr.ops, position.pos, avghr.abavg ORDER BY ops DESC LIMIT 2;`)
    })
    .then(function(results) {
      allResults.push(results)
    })
  //Second Base
    .then(function() {
      return db.query(`SELECT fullnames.namefirst, fullnames.namelast, CAST(avghr.ops as DECIMAL(4,3)), position.pos, avghr.abavg FROM batter_names as fullnames JOIN (SELECT avg(baseball.batting.ops) as ops, baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} GROUP BY idavg) as avghr ON fullnames.idall = avghr.idavg JOIN ( SELECT poslist.playerid, poslist.pos FROM position_occurence AS poslist LEFT JOIN position_occurence AS primarypos ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence WHERE primarypos.playerid IS NULL) as position ON avghr.idavg = position.playerid WHERE avghr.abavg > 350 AND position.pos = '2B' GROUP BY fullnames.namefirst, fullnames.namelast, avghr.ops, position.pos, avghr.abavg ORDER BY ops DESC LIMIT 2;`)
    })
    .then(function(results) {
      allResults.push(results)
    })
  //Shortstop
    .then(function() {
      return db.query(`SELECT fullnames.namefirst, fullnames.namelast, CAST(avghr.ops as DECIMAL(4,3)), position.pos, avghr.abavg FROM batter_names as fullnames JOIN (SELECT avg(baseball.batting.ops) as ops, baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} GROUP BY idavg) as avghr ON fullnames.idall = avghr.idavg JOIN ( SELECT poslist.playerid, poslist.pos FROM position_occurence AS poslist LEFT JOIN position_occurence AS primarypos ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence WHERE primarypos.playerid IS NULL) as position ON avghr.idavg = position.playerid WHERE avghr.abavg > 350 AND position.pos = 'SS' GROUP BY fullnames.namefirst, fullnames.namelast, avghr.ops, position.pos, avghr.abavg ORDER BY ops DESC LIMIT 2;`)
    })
    .then(function(results) {
      allResults.push(results)
    })
  //Third Base
    .then(function() {
      return db.query(`SELECT fullnames.namefirst, fullnames.namelast, CAST(avghr.ops as DECIMAL(4,3)), position.pos, avghr.abavg FROM batter_names as fullnames JOIN (SELECT avg(baseball.batting.ops) as ops, baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} GROUP BY idavg) as avghr ON fullnames.idall = avghr.idavg JOIN ( SELECT poslist.playerid, poslist.pos FROM position_occurence AS poslist LEFT JOIN position_occurence AS primarypos ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence WHERE primarypos.playerid IS NULL) as position ON avghr.idavg = position.playerid WHERE avghr.abavg > 350 AND position.pos = '3B' GROUP BY fullnames.namefirst, fullnames.namelast, avghr.ops, position.pos, avghr.abavg ORDER BY ops DESC LIMIT 2;`)
    })
    .then(function(results) {
      allResults.push(results)
    })
  //Catcher
    .then(function() {
      return db.query(`SELECT fullnames.namefirst, fullnames.namelast, CAST(avghr.ops as DECIMAL(4,3)), position.pos, avghr.abavg FROM batter_names as fullnames JOIN (SELECT avg(baseball.batting.ops) as ops, baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} GROUP BY idavg) as avghr ON fullnames.idall = avghr.idavg JOIN ( SELECT poslist.playerid, poslist.pos FROM position_occurence AS poslist LEFT JOIN position_occurence AS primarypos ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence WHERE primarypos.playerid IS NULL) as position ON avghr.idavg = position.playerid WHERE avghr.abavg > 350 AND position.pos = 'C' GROUP BY fullnames.namefirst, fullnames.namelast, avghr.ops, position.pos, avghr.abavg ORDER BY ops DESC LIMIT 2;`)
    })
    .then(function(results) {
      allResults.push(results)
    })
  //Starting pitcher
    .then(function() {
      return db.query(`SELECT avg(w) as avgwins, avg(ipouts) as avgipouts FROM baseball.pitching WHERE ipouts > 486 AND pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear};`)
    })
    .then(function(results) {
      var pitchConstraints = [results[0].avgwins, results[0].avgipouts];
      // console.log("avg wins"+results[0].avgwins+'; avg ipouts'+results[0].avgipouts)
      return pitchConstraints
    })
    .then(function(pitchConstraints){
      console.log("pitchConstraints: "+pitchConstraints)
    })
    .then(function(){
      resp.render('results.hbs', {
        outfield: allResults[0],
        firstbase:allResults[1],
        secondbase: allResults[2],
        shortstop: allResults[3],
        thirdbase: allResults[4],
        catcher: allResults[5],
        minYear: minYear,
        maxYear: maxYear});
    })
    .catch(function(err){
      console.error(err);
    })
});
