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
--Query the top homers averages of a given range by position INCOMPLETE, positions are numerous.
        --Attempting to aggregate out just the most often occurring position in a player's career
  SELECT fullnames.namefirst, fullnames.namelast, avghr.avghomer
  	FROM
  		(SELECT
    			baseball.batting.playerid as idall,
    			baseball.master.namefirst,
    			baseball.master.namelast,
          baseball.fielding.pos as pos
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
      JOIN (SELECT pos, COUNT(pos) as position_occurence, playerid
        FROM baseball.fielding
        GROUP BY pos, playerid
        ORDER BY position_occurence DESC
        LIMIT 1)
        as position
      ON baseball.batting.playerid = position.playerid

    GROUP BY fullnames.namefirst, fullnames.namelast, avghr.avghomer
    ORDER BY avghomer DESC;

--Query players by positions
  --Get occurence of positions that player has appeared in
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
  FROM (SELECT fielding.pos,
      count(fielding.pos) AS position_occurence,
      fielding.playerid
     FROM baseball.fielding
    GROUP BY fielding.pos, fielding.playerid
    )
    AS poslist
    LEFT JOIN (SELECT fielding.pos,
        count(fielding.pos) AS position_occurence,
        fielding.playerid
       FROM baseball.fielding
      GROUP BY fielding.pos, fielding.playerid
     ) AS primarypos
    ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence > poslist.position_occurence
    WHERE primarypos.playerid IS NULL;
