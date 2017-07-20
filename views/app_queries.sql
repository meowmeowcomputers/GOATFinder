const opsQuery = "SELECT fullnames.namefirst, fullnames.namelast, CAST(statavg.ops as DECIMAL(4,3)), position.pos, statavg.abavg FROM batter_names as fullnames JOIN (SELECT avg(baseball.batting.ops) as ops, baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON fullnames.idall = statavg.idavg JOIN ( SELECT poslist.playerid, poslist.pos FROM position_occurence AS poslist LEFT JOIN position_occurence AS primarypos ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence WHERE primarypos.playerid IS NULL) as position ON statavg.idavg = position.playerid WHERE statavg.abavg > 350 AND position.pos = ${pos}  GROUP BY fullnames.namefirst, fullnames.namelast, statavg.ops, position.pos, statavg.abavg ORDER BY ops DESC LIMIT ${limit};"

const hrQuery = "SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, CAST(statavg.hravg AS DECIMAL(5,2)), statavg.idavg as playerid FROM batter_names as fullnames JOIN (SELECT baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg, avg(baseball.batting.hr) as hravg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON fullnames.idall = statavg.idavg JOIN primary_position ON statavg.idavg = primary_position.playerid WHERE primary_position.pos = ${pos}  AND statavg.abavg > 350 GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.hravg, statavg.idavg ORDER BY statavg.hravg DESC LIMIT ${limit};"

const rbiQuery = "SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, CAST(statavg.rbiavg as DECIMAL(6,2)), statavg.idavg as playerid FROM batter_names as fullnames JOIN (SELECT baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg, avg(baseball.batting.rbi) as rbiavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON fullnames.idall = statavg.idavg JOIN primary_position ON statavg.idavg = primary_position.playerid WHERE primary_position.pos = ${pos}  AND statavg.abavg > 350 GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.rbiavg, statavg.idavg ORDER BY statavg.rbiavg DESC LIMIT ${limit};"

const rrbiQuery = "SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, CAST(statavg.rrbiavg as DECIMAL(6,2)), statavg.idavg as playerid FROM batter_names as fullnames JOIN (SELECT baseball.batting.playerid as idavg, avg(baseball.batting.ab) as abavg, avg(baseball.batting.rbi+baseball.batting.r) as rrbiavg FROM baseball.batting WHERE baseball.batting.yearid >= ${minYear} AND baseball.batting.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON fullnames.idall = statavg.idavg JOIN primary_position ON statavg.idavg = primary_position.playerid WHERE primary_position.pos = ${pos}  AND statavg.abavg > 350 GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.rrbiavg, statavg.idavg ORDER BY statavg.rrbiavg DESC LIMIT ${limit};"

const spWinsQuery = "SELECT CAST(statavg.avgera as DECIMAL(4,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgipouts as average_outs_per_year, statavg.totalwins, CAST(statavg.avgwhip as DECIMAL(4,3)) FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.w) as totalwins, avg(pitching.w) as avgwins, avg(pitching.whip) as avgwhip FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgipouts > ${ipFloor} GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, average_outs_per_year, statavg.totalwins, statavg.avgwhip ORDER BY statavg.totalwins DESC LIMIT ${limit}"

const spEraQuery = "SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgipouts as average_outs_per_year, statavg.totalwins, CAST(statavg.avgwhip as DECIMAL(5,3)) FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.w) as totalwins, avg(pitching.w) as avgwins, avg(pitching.whip) as avgwhip FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgipouts > ${ipFloor} GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, average_outs_per_year, statavg.totalwins, statavg.avgwhip ORDER BY statavg.avgera ASC LIMIT ${limit};"

const spWhipQuery ="SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgipouts as average_outs_per_year, statavg.totalwins, CAST(statavg.avgwhip as DECIMAL(5,3)) FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.w) as totalwins, avg(pitching.w) as avgwins, avg(pitching.whip) as avgwhip FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgipouts > ${ipFloor} GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, average_outs_per_year, statavg.totalwins, statavg.avgwhip ORDER BY statavg.avgwhip ASC LIMIT ${limit};"

const bpSaveQuery ="SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(statavg.avgwhip as DECIMAL(5,3)), statavg.totalsaves, statavg.avgsaves, statavg.totalso FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, avg(pitching.ipouts) as avgipouts, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgwhip < 2 GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgwhip, statavg.totalsaves, statavg.avgsaves, statavg.totalso ORDER BY ROUND(totalsaves, -1) desc, statavg.avgwhip asc LIMIT 4;"

const bpWhipQuery = "SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(statavg.avgwhip as DECIMAL(5,3)), statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso, avg(pitching.w) as avgwins, sum(pitching.g) as totalgames FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} AND pitching.g > 10 GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgwhip < 2 AND avgwins < 12 AND totalgames > 100 GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgwhip, statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins ORDER BY statavg.avgwhip asc LIMIT ${limit};"

const bpEraQuery = "SELECT CAST(statavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(statavg.avgwhip as DECIMAL(5,3)), statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins FROM pitcher_names JOIN (SELECT avg(pitching.era) as avgera, pitching.playerid as idavg, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso, avg(pitching.w) as avgwins, sum(pitching.g) as totalgames FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} AND pitching.g > 10 GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgwhip < 2 AND avgwins < 12 AND totalgames > 100 GROUP BY statavg.avgera, pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgwhip, statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins ORDER BY statavg.avgera asc LIMIT ${limit};"

const bpSoipQuery = "SELECT pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, CAST(statavg.avgwhip as DECIMAL(5,3)), statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins, CAST(statavg.soperip as DECIMAL(5,3)) FROM pitcher_names JOIN (SELECT sum(pitching.so)/sum(pitching.real_ip) as soperip, pitching.playerid as idavg, sum(pitching.sv) as totalsaves, avg(pitching.sv) as avgsaves, avg(pitching.whip) as avgwhip, sum(pitching.so) as totalso, avg(pitching.w) as avgwins, sum(pitching.g) as totalgames FROM baseball.pitching WHERE pitching.yearid >= ${minYear} AND pitching.yearid <= ${maxYear} ${team^} AND pitching.g > 10 GROUP BY idavg) as statavg ON statavg.idavg = pitcher_names.playerid WHERE statavg.avgwhip < 2 AND avgwins <10 AND totalgames > 30 AND totalso > 100 GROUP BY pitcher_names.fname, pitcher_names.lname, pitcher_names.playerid, statavg.avgwhip, statavg.totalsaves, statavg.avgsaves, statavg.totalso, statavg.avgwins,statavg.soperip ORDER BY statavg.soperip desc LIMIT ${limit};"