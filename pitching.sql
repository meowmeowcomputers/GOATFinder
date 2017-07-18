
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
  JOIN baseball.fielding
  ON baseball.fielding.playerid = eraavg.idavg
  WHERE eraavg.avgipouts > 659-100
  AND CAST(baseball.fielding.gs as int) > 10
  GROUP BY eraavg.avgera, pitcher_names.fname, pitcher_names.lname,
    pitcher_names.playerid, average_outs_per_year, eraavg.totalwins, eraavg.avgwhip
  ORDER BY eraavg.avgwhip ASC;

--Same query as above ready to be inserted into index.js
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
  JOIN baseball.fielding
  ON baseball.fielding.playerid = eraavg.idavg
  WHERE eraavg.avgipouts > 659-100
  AND CAST(baseball.fielding.gs as int) > 10
  GROUP BY eraavg.avgera, pitcher_names.fname, pitcher_names.lname,
    pitcher_names.playerid, average_outs_per_year, eraavg.totalwins, eraavg.avgwhip
  ORDER BY eraavg.avgwhip ASC;


--Generate the ipouts/wins threshhold by year
SELECT avg(w) as avgwins, avg(ipouts) as avgipouts FROM baseball.pitching WHERE ipouts > 486 AND pitching.yearid >= 2000 AND pitching.yearid <= 2016;
