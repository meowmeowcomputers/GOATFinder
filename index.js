"use strict";

const express = require("express");
const app = express();
const body_parser = require("body-parser");
const session = require("express-session");

/*************** Database ***************/
const promise = require("bluebird");
const pgp = require("pg-promise")({
  promiseLib: promise
});
//Development database settings
const db = pgp(
  process.env.DATABASE_URL || {
    host: "localhost",
    port: 5432,
    database: "baseball",
    user: "postgres"
  }
);
/*********** App Configuration **************/
var hbs = require("hbs");
app.set("view engine", "hbs");
hbs.registerPartials("views/partials");

app.use("/static", express.static("static"));
app.use(body_parser.urlencoded({ extended: false }));
app.use(body_parser.json());

let PORT = process.env.PORT || 9000;
app.listen(PORT, function() {
  console.log("Listening on port " + PORT);
});

app.get("/", function(req, resp) {
  resp.render("index.hbs");
});

app.get("/submit", function(req, resp) {
  resp.render("index.hbs");
});
//Queries to database
const opsQuery =
  "SELECT fullnames.namefirst, fullnames.namelast, CAST(statavg.ops as DECIMAL(4,3)), position.pos, statavg.abavg FROM batter_names as fullnames JOIN (SELECT avg(baseball.batting.ops) as ops, baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON fullnames.idall = statavg.idavg JOIN ( SELECT poslist.playerid, poslist.pos FROM position_occurence AS poslist LEFT JOIN position_occurence AS primarypos ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence WHERE primarypos.playerid IS NULL) as position ON statavg.idavg = position.playerid WHERE statavg.abavg > 350 AND position.pos = ${pos}  GROUP BY fullnames.namefirst, fullnames.namelast, statavg.ops, position.pos, statavg.abavg ORDER BY ops DESC LIMIT ${limit};";

const hrQuery =
  "SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, CAST(statavg.hravg AS DECIMAL(5,2)), statavg.idavg as playerid FROM batter_names as fullnames JOIN (SELECT baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg, avg(baseball.batting.hr) as hravg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON fullnames.idall = statavg.idavg JOIN primary_position ON statavg.idavg = primary_position.playerid WHERE primary_position.pos = ${pos}  AND statavg.abavg > 350 GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.hravg, statavg.idavg ORDER BY statavg.hravg DESC LIMIT ${limit};";

const rbiQuery =
  "SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, CAST(statavg.rbiavg as DECIMAL(6,2)), statavg.idavg as playerid FROM batter_names as fullnames JOIN (SELECT baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg, avg(baseball.batting.rbi) as rbiavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON fullnames.idall = statavg.idavg JOIN primary_position ON statavg.idavg = primary_position.playerid WHERE primary_position.pos = ${pos}  AND statavg.abavg > 350 GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.rbiavg, statavg.idavg ORDER BY statavg.rbiavg DESC LIMIT ${limit};";

const rrbiQuery =
  "SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, CAST(statavg.rrbiavg as DECIMAL(6,2)), statavg.idavg as playerid FROM batter_names as fullnames JOIN (SELECT baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg, avg(baseball.batting.rbi+baseball.batting.r) as rrbiavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON fullnames.idall = statavg.idavg JOIN primary_position ON statavg.idavg = primary_position.playerid WHERE primary_position.pos = ${pos}  AND statavg.abavg > 350 GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.rrbiavg, statavg.idavg ORDER BY statavg.rrbiavg DESC LIMIT ${limit};";

const spWinsQuery =
  "SELECT CAST(statavg.avgera as DECIMAL(4,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgipouts as average_outs_per_year, statavg.totalwins, CAST(statavg.avgwhip as DECIMAL(4,3)) FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.w) as totalwins, avg(pitching.w) as avgwins, avg(pitching.whip) as avgwhip FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgipouts > ${ipFloor} GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, average_outs_per_year, statavg.totalwins, statavg.avgwhip ORDER BY statavg.totalwins DESC LIMIT ${limit}";

const spEraQuery =
  "SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgipouts as average_outs_per_year, statavg.totalwins, CAST(statavg.avgwhip as DECIMAL(5,3)) FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.w) as totalwins, avg(pitching.w) as avgwins, avg(pitching.whip) as avgwhip FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgipouts > ${ipFloor} GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, average_outs_per_year, statavg.totalwins, statavg.avgwhip ORDER BY statavg.avgera ASC LIMIT ${limit};";

const spWhipQuery =
  "SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgipouts as average_outs_per_year, statavg.totalwins, CAST(statavg.avgwhip as DECIMAL(5,3)) FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.w) as totalwins, avg(pitching.w) as avgwins, avg(pitching.whip) as avgwhip FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgipouts > ${ipFloor} GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, average_outs_per_year, statavg.totalwins, statavg.avgwhip ORDER BY statavg.avgwhip ASC LIMIT ${limit};";

const bpSaveQuery =
  "SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(statavg.avgwhip as DECIMAL(5,3)), statavg.totalsaves, statavg.avgsaves, statavg.totalso FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgwhip < 2 GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgwhip, statavg.totalsaves, statavg.avgsaves, statavg.totalso ORDER BY ROUND(totalsaves, -1) desc, statavg.avgwhip asc LIMIT 4;";

const bpWhipQuery =
  "SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(statavg.avgwhip as DECIMAL(5,3)), statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso, avg(pitching.w) as avgwins, sum(pitching.g) as totalgames FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} AND pitching.g > 10 GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgwhip < 2 AND avgwins < 12 AND totalgames > 100 GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgwhip, statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins ORDER BY statavg.avgwhip asc LIMIT ${limit};";

const bpEraQuery =
  "SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(statavg.avgwhip as DECIMAL(5,3)), statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso, avg(pitching.w) as avgwins, sum(pitching.g) as totalgames FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} AND pitching.g > 10 GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgwhip < 2 AND avgwins < 12 AND totalgames > 100 GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgwhip, statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins ORDER BY statavg.avgera asc LIMIT ${limit};";

const bpSoipQuery =
  "SELECT pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(statavg.avgwhip as DECIMAL(5,3)), statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins, CAST(statavg.soperip as DECIMAL(5,3)) FROM pitcher_names JOIN (SELECT sum(pitching.so)/sum(pitching.real_ip) as soperip, pitching.playerid as idavg, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso, avg(pitching.w) as avgwins, sum(pitching.g) as totalgames FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} AND pitching.g > 10 GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgwhip < 2 AND avgwins <10 AND totalgames > 30 AND totalso > 100 GROUP BY pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgwhip, statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins,statavg.soperip ORDER BY statavg.soperip desc LIMIT ${limit};";

app.post("/submit", function(req, resp) {
  // console.log('Minimum year: '+req.body.min_slider)
  // console.log('Maximum year: '+req.body.max_slider)
  var posQuery;
  var pitchQuery;
  var bullpenQuery;
  var minYear = req.body.min_slider;
  var maxYear = req.body.max_slider;
  var allResults = [];
  var retainMenu = {};
  var teamBat = [];
  var teamPitch = [];
  if (req.body.league_team) {
    teamBat.push(
      " AND baseball.batting.teamid = '" + req.body.league_team + "' "
    );
    teamPitch.push(
      " AND baseball.pitching.teamid = '" + req.body.league_team + "' "
    );
    retainMenu[req.body.league_team] = 1;
  }
  teamBat = teamBat.join("");
  teamPitch = teamPitch.join("");

  if (req.body.bullpen == "bp_sv") {
    bullpenQuery = bpSaveQuery;
    retainMenu.bp_sv = 1;
  } else if (req.body.bullpen == "bp_era") {
    bullpenQuery = bpEraQuery;
    retainMenu.bp_era = 1;
  } else if (req.body.bullpen == "bp_soip") {
    bullpenQuery = bpSoipQuery;
    retainMenu.bp_soip = 1;
  } else if (req.body.bullpen == "bp_whip") {
    bullpenQuery = bpWhipQuery;
    retainMenu.bp_whip = 1;
  }

  // console.log("Batter weight property: "+req.body.batting)
  // Check which batting weight the user selected
  if (req.body.batting == "ops") {
    posQuery = opsQuery;
    retainMenu.ops = 1;
  } else if (req.body.batting == "hr") {
    posQuery = hrQuery;
    retainMenu.hr = 1;
  } else if (req.body.batting == "rbi") {
    posQuery = rbiQuery;
    retainMenu.rbi = 1;
  } else if (req.body.batting == "rrbi") {
    posQuery = rrbiQuery;
    retainMenu.rrbi = 1;
  } else {
    posQuery = opsQuery;
    retainMenu.ops = 1;
  }
  //Check which starting pitching weight the user selected
  if (req.body.starters == "sp_whip") {
    pitchQuery = spWhipQuery;
    retainMenu.sp_whip = 1;
  } else if (req.body.starters == "sp_era") {
    pitchQuery = spEraQuery;
    retainMenu.sp_era = 1;
  } else if (req.body.starters == "sp_wins") {
    pitchQuery = spWinsQuery;
    retainMenu.sp_wins = 1;
  } else {
    pitchQuery = spWinsQuery;
    retainMenu.sp_wins = 1;
  }
  //Outfielder search
  db
    .query(posQuery, {
      minYear: minYear,
      maxYear: maxYear,
      team: teamBat,
      pos: "OF",
      limit: 6
    })
    .then(function(results) {
      allResults.push(results);
      console.log(results[0]);
    })
    //First Base
    .then(function() {
      return db.query(posQuery, {
        minYear: minYear,
        maxYear: maxYear,
        team: teamBat,
        pos: "1B",
        limit: 2
      });
    })
    .then(function(results) {
      allResults.push(results);
    })
    //Second Base
    .then(function() {
      return db.query(posQuery, {
        minYear: minYear,
        maxYear: maxYear,
        team: teamBat,
        pos: "2B",
        limit: 2
      });
    })
    .then(function(results) {
      allResults.push(results);
    })
    //Shortstop
    .then(function() {
      return db.query(posQuery, {
        minYear: minYear,
        maxYear: maxYear,
        team: teamBat,
        pos: "SS",
        limit: 2
      });
    })
    .then(function(results) {
      allResults.push(results);
    })
    //Third Base
    .then(function() {
      return db.query(posQuery, {
        minYear: minYear,
        maxYear: maxYear,
        team: teamBat,
        pos: "3B",
        limit: 2
      });
    })
    .then(function(results) {
      allResults.push(results);
    })
    //Catcher
    .then(function() {
      return db.query(posQuery, {
        minYear: minYear,
        maxYear: maxYear,
        team: teamBat,
        pos: "C",
        limit: 2
      });
    })
    .then(function(results) {
      allResults.push(results);
    })
    //Starting pitcher, query to constrain ip average by year window
    .then(function() {
      return db.query(
        `SELECT avg(w) as avgwins, avg(ipouts) as avgipouts FROM baseball.pitching WHERE ipouts > 486 AND pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear};`
      );
    })
    .then(function(results) {
      var ipFloor = results[0].avgipouts - 100;
      return ipFloor;
    })
    //Starting pitcher query
    .then(function(ipFloor) {
      return db.query(pitchQuery, {
        minYear: minYear,
        maxYear: maxYear,
        team: teamPitch,
        limit: 5,
        ipFloor: ipFloor
      });
    })
    .then(function(results) {
      allResults.push(results);
    })
    //bullpen
    .then(function(pitchConstraints) {
      return db.query(bullpenQuery, {
        minYear: minYear,
        maxYear: maxYear,
        team: teamPitch,
        limit: 5
      });
    })
    .then(function(results) {
      allResults.push(results);
    })
    .then(function() {
      resp.render("results.hbs", {
        outfield: allResults[0],
        firstbase: allResults[1],
        secondbase: allResults[2],
        shortstop: allResults[3],
        thirdbase: allResults[4],
        catcher: allResults[5],
        startingPitcher: allResults[6],
        bullpen: allResults[7],
        minYear: minYear,
        maxYear: maxYear,
        retainMenu: retainMenu
      });
    })
    .catch(function(err) {
      console.error(err);
    });
});
