-- Add batting averages, 4 decimal points
UPDATE baseball.batting SET avg = CAST(h as FLOAT)/CAST(ab as FLOAT) WHERE ab > 0;
--Query the home run averages for a given year range
SELECT fullnames.namefirst, fullnames.namelast, avghr.avghomer
	FROM
		(SELECT
			baseball.batting.playerid as idall,
			baseball.master.namefirst,
			baseball.master.namelast
  				FROM baseball.batting
  		JOIN baseball.master
  		ON baseball.master.playerid = baseball.batting.playerid
  		WHERE baseball.batting.yearid >= 1871
  		AND baseball.batting.yearid <= 2016)
  		as fullnames
  	JOIN
  		(SELECT
	  		avg(baseball.batting.hr) as avghomer,
	  		baseball.batting.playerid as idavg
  				FROM baseball.batting
 		GROUP BY idavg)
 		as avghr
 	ON fullnames.idall = avghr.idavg
  GROUP BY fullnames.namefirst, fullnames.namelast, avghr.avghomer
  ORDER BY avghomer DESC;
--Query the top homers averages of a given year range by position
        SELECT fullnames.namefirst, fullnames.namelast, avghr.avghomer, position.pos
        	FROM
          --Get player full names from master table
        		(SELECT
          			baseball.batting.playerid as idall,
          			baseball.master.namefirst,
          			baseball.master.namelast
          		FROM baseball.batting
          		JOIN baseball.master
          		  ON baseball.master.playerid = baseball.batting.playerid)
          		as fullnames
          --Get homer averages and constrain by year
          	JOIN
          		(SELECT
        	  		avg(baseball.batting.hr) as avghomer,
        	  		baseball.batting.playerid as idavg
        				FROM baseball.batting
                WHERE baseball.batting.yearid >= 1800
                AND baseball.batting.yearid <= 2016
       		      GROUP BY idavg)
         		   as avghr
         	  ON fullnames.idall = avghr.idavg
          --Get primary player positions
            JOIN (  SELECT poslist.playerid, poslist.pos
              FROM (  SELECT fielding.pos,
                sum(fielding.g) AS position_occurence,
                fielding.playerid
               FROM baseball.fielding
              GROUP BY fielding.pos, fielding.playerid
                )
                AS poslist
                LEFT JOIN (  SELECT fielding.pos,
                sum(fielding.g) AS position_occurence,
                fielding.playerid
               FROM baseball.fielding
              GROUP BY fielding.pos, fielding.playerid
                 ) AS primarypos
                ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence >
                 poslist.position_occurence
                WHERE primarypos.playerid IS NULL)
              as position
           ON avghr.idavg = position.playerid
      --     WHERE position.pos = ''
          GROUP BY fullnames.namefirst, fullnames.namelast, avghr.avghomer, position.pos
          ORDER BY avghomer DESC
          LIMIT 1000;

--Query players by positions
  --Get occurence of positions that player has appeared in (generates view position_occ)
  SELECT fielding.pos,
    count(fielding.pos) AS position_occurence,
    fielding.playerid
   FROM baseball.fielding
  GROUP BY fielding.pos, fielding.playerid
  ORDER BY (count(fielding.pos));
  --Get primary position of player from view position_occ of query above
  SELECT poslist.playerid, poslist.pos
	FROM baseball.position_occ AS poslist
		LEFT JOIN baseball.position_occ AS primarypos
    ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence
		WHERE primarypos.playerid IS NULL;
  --Aggregate query without view to produce the playerid list and position that they primarily play
  SELECT poslist.playerid, poslist.pos
  FROM (  SELECT fielding.pos,
    sum(fielding.g) AS position_occurence,
    fielding.playerid
   FROM baseball.fielding
  GROUP BY fielding.pos, fielding.playerid
    )
    AS poslist
    LEFT JOIN (  SELECT fielding.pos,
    sum(fielding.g) AS position_occurence,
    fielding.playerid
   FROM baseball.fielding
  GROUP BY fielding.pos, fielding.playerid
     ) AS primarypos
    ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence
    WHERE primarypos.playerid IS NULL;

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
--Query to find top bullpen players

UPDATE baseball.pitching SET ip = CAST(ipouts as FLOAT)/3 WHERE ipouts > 0;
