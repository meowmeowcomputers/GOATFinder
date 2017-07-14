
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
  GROUP BY eraavg.avgera, pitching.fname, pitching.lname, pitching.playerid, average_outs_per_year
  ORDER BY eraavg.avgera ASC;

--Query the top starting pitchers by WHIP
SELECT eraavg.avgwhip, pitching.fname, pitching.lname, pitching.playerid, eraavg.avgipouts as average_outs_per_year FROM
  (SELECT master.namefirst as fname, master.namelast as lname, pitching.*
    FROM baseball.pitching AS pitching
    JOIN baseball.master AS master
    ON master.playerid = pitching.playerid
 ) as pitching
  JOIN
  (SELECT
    avg(pitching.whip) as avgwhip,
    pitching.playerid as idavg,
    avg(pitching.ipouts) as avgipouts
    FROM baseball.pitching
    WHERE pitching.yearid >= 2015
    AND pitching.yearid <= 2016
    GROUP BY idavg) as eraavg
  ON eraavg.idavg = pitching.playerid
  AND eraavg.avgipouts > 486
  GROUP BY eraavg.avgwhip, pitching.fname, pitching.lname, pitching.playerid, average_outs_per_year
  ORDER BY eraavg.avgwhip ASC;
--Query to find top bullpen players
