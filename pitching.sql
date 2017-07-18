
--Query the pitcher names
SELECT  master.namefirst, master.namelast, pitching.*
  FROM baseball.pitching AS pitching
  JOIN baseball.master AS master
  ON master.playerid = pitching.playerid
  WHERE pitching.yearid >= 1871
  AND pitching.yearid <= 2016
--Query the top starting pitchers within a given date range by average ERA and
  --innings pitched per year meets ERA championship qualifier
SELECT eraavg.avgera, pitching.fname, pitching.lname, pitching.playerid, eraavg.avgipouts as average_outs_per_year FROM
  (SELECT master.namefirst as fname, master.namelast as lname, pitching.*
    FROM baseball.pitching AS pitching
    JOIN baseball.master AS master
    ON master.playerid = pitching.playerid
 ) as pitching
  JOIN
  (SELECT
    avg(pitching.era) as avgera,
    pitching.playerid as idavg,
    avg(pitching.ipouts) as avgipouts
    FROM baseball.pitching
    WHERE pitching.yearid >= 2015
    AND pitching.yearid <= 2016
    GROUP BY idavg) as eraavg
  ON eraavg.idavg = pitching.playerid
  AND eraavg.avgipouts > 486
  GROUP BY eraavg.avgera, pitching.fname, pitching.lname, pitching.playerid, average_outs_per_year, eraavg.avgwins
  ORDER BY eraavg.avgera ASC;

--Query the top starting pitchers by ERA
SELECT eraavg.avgera, pitching.fname, pitching.lname,
  pitching.playerid, eraavg.avgipouts as average_outs_per_year, eraavg.avgwins
  FROM
    (SELECT master.namefirst as fname, master.namelast as lname, pitching.*
    FROM baseball.pitching AS pitching
    JOIN baseball.master AS master
    ON master.playerid = pitching.playerid
    ) as pitching
  JOIN
  (SELECT
    avg(pitching.era) as avgera,
    pitching.playerid as idavg,
    avg(pitching.ipouts) as avgipouts,
    sum(pitching.w) as avgwins
    FROM baseball.pitching
    WHERE pitching.yearid >= 1871
    AND pitching.yearid <= 2016
    GROUP BY idavg) as eraavg
  ON eraavg.idavg = pitching.playerid
  JOIN baseball.fielding
  ON baseball.fielding.playerid = eraavg.idavg
  WHERE eraavg.avgipouts > 486
  AND gs > 10
  GROUP BY eraavg.avgera, pitching.fname, pitching.lname,
    pitching.playerid, average_outs_per_year, eraavg.avgwins
  ORDER BY eraavg.avgera ASC;
--Query the top starting pitchers by ERA
SELECT eraavg.avgera, pitcher_names.fname, pitcher_names.lname,
  pitcher_names.playerid, eraavg.avgipouts as average_outs_per_year, eraavg.totalwins, eraavg.avgwhip
  FROM
    pitcher_names
  JOIN
  (SELECT
    avg(pitching.era) as avgera,
    pitching.playerid as idavg,
    avg(pitching.ipouts) as avgipouts,
    sum(pitching.w) as totalwins,
    avg(pitching.w) as avgwins,
    avg(pitching.whip) as avgwhip
    FROM baseball.pitching
    WHERE pitching.yearid >= 1871
    AND pitching.yearid <= 2016
    GROUP BY idavg) as eraavg
  ON eraavg.idavg = pitcher_names.playerid
  WHERE eraavg.avgipouts > 659-100
  GROUP BY eraavg.avgera, pitcher_names.fname, pitcher_names.lname,
    pitcher_names.playerid, average_outs_per_year, eraavg.totalwins, eraavg.avgwhip
  ORDER BY eraavg.totalwins DESC;
--Same query as above ready to be inserted into index.js
SELECT CAST(eraavg.avgera as DECIMAL(4,3)), pitcher_names.fname, pitcher_names.lname,
  pitcher_names.playerid, eraavg.avgipouts as average_outs_per_year, eraavg.totalwins, CAST(eraavg.avgwhip as DECIMAL(4,3))
  FROM
    pitcher_names
  JOIN
  (SELECT
    avg(pitching.era) as avgera,
    pitching.playerid as idavg,
    avg(pitching.ipouts) as avgipouts,
    sum(pitching.w) as totalwins,
    avg(pitching.w) as avgwins,
    avg(pitching.whip) as avgwhip
    FROM baseball.pitching
    WHERE pitching.yearid >= ${minYear}
    AND pitching.yearid <= ${maxYear}
    GROUP BY idavg) as eraavg
  ON eraavg.idavg = pitcher_names.playerid
  WHERE eraavg.avgipouts > ${pitchConstraints[1]}-100
  GROUP BY eraavg.avgera, pitcher_names.fname, pitcher_names.lname,
    pitcher_names.playerid, average_outs_per_year, eraavg.totalwins, eraavg.avgwhip
  ORDER BY eraavg.totalwins DESC;
--Generate the ipouts/wins threshhold by year for starters
SELECT avg(w) as avgwins, avg(ipouts) as avgipouts FROM baseball.pitching WHERE ipouts > 486 AND pitching.yearid >= 2000 AND pitching.yearid <= 2016;

--Query to find bullpen
SELECT CAST(eraavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname,
  pitcher_names.playerid, CAST(eraavg.avgwhip as DECIMAL(5,3)),
  eraavg.totalsaves, eraavg.avgsaves, eraavg.totalso
  FROM
    pitcher_names
  JOIN
  (SELECT
    avg(pitching.era) as avgera,
    pitching.playerid as idavg,
    avg(pitching.ipouts) as avgipouts,
	sum(pitching.sv) as totalsaves,
	avg(pitching.sv) as avgsaves,
    avg(pitching.whip) as avgwhip,
    sum(pitching.so) as totalso
    FROM baseball.pitching
    WHERE pitching.yearid >= 1871
    AND pitching.yearid <= 1930
    GROUP BY idavg) as eraavg
  ON eraavg.idavg = pitcher_names.playerid
	WHERE eraavg.avgwhip < 2

  GROUP BY eraavg.avgera, pitcher_names.fname, pitcher_names.lname,
    pitcher_names.playerid, eraavg.avgwhip, eraavg.totalsaves, eraavg.avgsaves, eraavg.totalso

  ORDER BY ROUND(totalsaves, -1) desc, eraavg.avgwhip asc
  LIMIT 5;
  --Same query as above ready to be inserted into index.js
  SELECT CAST(eraavg.avgera as DECIMAL(5,3)), pitcher_names.fname, pitcher_names.lname,
    pitcher_names.playerid, CAST(eraavg.avgwhip as DECIMAL(5,3)),
    eraavg.totalsaves, eraavg.avgsaves, eraavg.totalso
    FROM
      pitcher_names
    JOIN
    (SELECT
      avg(pitching.era) as avgera,
      pitching.playerid as idavg,
      avg(pitching.ipouts) as avgipouts,
  	sum(pitching.sv) as totalsaves,
  	avg(pitching.sv) as avgsaves,
      avg(pitching.whip) as avgwhip,
      sum(pitching.so) as totalso
      FROM baseball.pitching
      WHERE pitching.yearid >= ${minYear}
      AND pitching.yearid <= ${maxYear}
      GROUP BY idavg) as eraavg
    ON eraavg.idavg = pitcher_names.playerid
  	WHERE eraavg.avgwhip < 2

    GROUP BY eraavg.avgera, pitcher_names.fname, pitcher_names.lname,
      pitcher_names.playerid, eraavg.avgwhip, eraavg.totalsaves, eraavg.avgsaves, eraavg.totalso

    ORDER BY ROUND(totalsaves, -1) desc, eraavg.avgwhip asc
    LIMIT 5;
