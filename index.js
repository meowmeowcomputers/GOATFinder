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
  var gap = maxYear - minYear
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
  //Starting pitcher, query to constrain ip average by year window
    .then(function() {
      return db.query(`SELECT avg(w) as avgwins, avg(ipouts) as avgipouts FROM baseball.pitching WHERE ipouts > 486 AND pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear};`)
    })
    .then(function(results) {
      var pitchConstraints = [results[0].avgwins, results[0].avgipouts];
      return pitchConstraints
    })
  //Starting pitcher query
    .then(function(pitchConstraints){
      return db.query(`SELECT CAST(eraavg.avgera as DECIMAL(4,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, eraavg.avgipouts as average_outs_per_year, eraavg.totalwins, CAST(eraavg.avgwhip as DECIMAL(4,3)) FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.w) as totalwins, avg(pitching.w) as avgwins, avg(pitching.whip) as avgwhip FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} GROUP BY idavg) as eraavg ON eraavg.idavg = pitcher_names.playerid WHERE eraavg.avgipouts > ${pitchConstraints[1]}-100 GROUP BY eraavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, average_outs_per_year, eraavg.totalwins, eraavg.avgwhip ORDER BY eraavg.totalwins DESC LIMIT 5;`)
    })
    .then(function(results) {
        allResults.push(results)
    })
  //bullpen
    .then(function(pitchConstraints){
      return db.query(`SELECT CAST(eraavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(eraavg.avgwhip as DECIMAL(5,3)), eraavg.totalsaves, eraavg.avgsaves, eraavg.totalso FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} GROUP BY idavg) as eraavg ON eraavg.idavg = pitcher_names.playerid WHERE eraavg.avgwhip < 2 GROUP BY eraavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, eraavg.avgwhip, eraavg.totalsaves, eraavg.avgsaves, eraavg.totalso ORDER BY ROUND(totalsaves, -1) desc, eraavg.avgwhip asc LIMIT 4;`)
    })
    .then(function(results) {
        allResults.push(results)
    })
    .then(function(){
      resp.render('results.hbs', {
        outfield: allResults[0],
        firstbase:allResults[1],
        secondbase: allResults[2],
        shortstop: allResults[3],
        thirdbase: allResults[4],
        catcher: allResults[5],
        startingPitcher: allResults[6],
        bullpen: allResults[7],
        minYear: minYear,
        maxYear: maxYear});
    })
    .catch(function(err){
      console.error(err);
    })
});
