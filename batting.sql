ALTER TABLE "baseball"."batting" add ibbint bigint;
;
UPDATE "baseball"."batting" SET hbp = 0 WHERE hbp ='';


UPDATE "baseball"."batting" SET sh = 0 WHERE sh =''

UPDATE "baseball"."batting" SET sf = 0 WHERE sf =''

UPDATE "baseball"."batting" SET gidp = 0 WHERE gidp =''

-- Add batting averages, 4 decimal points
UPDATE baseball.batting SET avg = CAST(h as FLOAT)/CAST(ab as FLOAT) WHERE ab > 0;
--Add OPS
UPDATE baseball.batting
SET ops =
(
	CAST(ab as FLOAT) *
	(
		CAST(h as FLOAT)
		+CAST(bb as FLOAT)
		+CAST(hbp as FLOAT)
	) +
	--TB
	(
		CAST(h as FLOAT)
		+ (CAST("2B" as FLOAT))
		+(CAST("3B" as FLOAT)*2)
		+(CAST(hr as FLOAT)*3)
	) *
	--Slugging
	(
		(CAST(ab as FLOAT)
		+CAST(hbp as FLOAT)
		+CAST(bb as FLOAT)
		+CAST(sf as FLOAT)
		)
	)
)
/
(
	CAST(ab as FLOAT) *

		(CAST(ab as FLOAT)
		+CAST(hbp as FLOAT)
		+CAST(bb as FLOAT)
		+CAST(sf as FLOAT)
		)
)
/CAST(ab as FLOAT) WHERE ab > 0;
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
                ) AS poslist
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
          LIMIT 10;

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

--Query the top ops averages of a given year range by position, but with materialized views to improve performance
SELECT fullnames.namefirst, fullnames.namelast, avghr.ops, position.pos, avghr.abavg
				FROM
				--Get player full names from master table
					batter_names
						as fullnames
				--Get homer averages and constrain by year
					JOIN
						(SELECT
							avg(baseball.batting.ops) as ops,
							baseball.batting.playerid as idavg,
							avg(baseball.batting.ab) as abavg
							FROM baseball.batting
							WHERE baseball.batting.yearid >= 1800
							AND baseball.batting.yearid <= 2016
							GROUP BY idavg)
						 as avghr
					ON fullnames.idall = avghr.idavg
				--Get primary player positions
					JOIN (  SELECT poslist.playerid, poslist.pos
						FROM position_occurence
							AS poslist
							LEFT JOIN position_occurence AS primarypos
							ON primarypos.playerid=poslist.playerid AND primarypos.position_occurence >
							 poslist.position_occurence
							WHERE primarypos.playerid IS NULL
							AND poslist.pos != 'P')
						as position
				 ON avghr.idavg = position.playerid
		--     WHERE position.pos = ''
				WHERE avghr.abavg > 500
				GROUP BY fullnames.namefirst, fullnames.namelast, avghr.ops, position.pos, avghr.abavg
				ORDER BY ops DESC
				LIMIT 10;
--Query the top homer hitters by position
SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.hravg, statavg.idavg as playerid
				FROM
				--Get player full names from master table
					batter_names
						as fullnames
				--Get homer averages and constrain by year
					JOIN
						(SELECT
							baseball.batting.playerid as idavg,
							avg(baseball.batting.ab) as abavg,
							avg(baseball.batting.hr) as hravg
							FROM baseball.batting
							WHERE baseball.batting.yearid >= 1800
							AND baseball.batting.yearid <= 2016
							GROUP BY idavg)
						 as statavg
					ON fullnames.idall = statavg.idavg
				--Get primary player positions
					JOIN primary_position
				 ON statavg.idavg = primary_position.playerid
		    WHERE primary_position.pos = 'OF'
			AND statavg.abavg > 350
				GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, 	statavg.hravg, statavg.idavg
				ORDER BY statavg.hravg DESC
				LIMIT 6;
--Same above query with parameters
SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.hravg, statavg.idavg as playerid
				FROM
					batter_names
						as fullnames
					JOIN
						(SELECT
							baseball.batting.playerid as idavg,
							avg(baseball.batting.ab) as abavg,
							avg(baseball.batting.hr) as hravg
							FROM baseball.batting
							WHERE baseball.batting.yearid >= ${minYear}
							AND baseball.batting.yearid <= ${maxYear}
							GROUP BY idavg)
						 as statavg
					ON fullnames.idall = statavg.idavg
					JOIN primary_position
				 ON statavg.idavg = primary_position.playerid
		    WHERE primary_position.pos = ${pos}
			AND statavg.abavg > 350
				GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, 	statavg.hravg, statavg.idavg
				ORDER BY statavg.hravg DESC
				LIMIT ${limit};
--Query to find most rbi
SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.rbiavg, statavg.idavg as playerid
				FROM
				--Get player full names from master table
					batter_names
						as fullnames
				--Get homer averages and constrain by year
					JOIN
						(SELECT
							baseball.batting.playerid as idavg,
							avg(baseball.batting.ab) as abavg,
							avg(baseball.batting.rbi) as rbiavg
							FROM baseball.batting
							WHERE baseball.batting.yearid >= 1800
							AND baseball.batting.yearid <= 2016
							GROUP BY idavg)
						 as statavg
					ON fullnames.idall = statavg.idavg
				--Get primary player positions
					JOIN primary_position
				 ON statavg.idavg = primary_position.playerid
		  --  WHERE primary_position.pos = 'OF'
			AND statavg.abavg > 350
				GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, 	statavg.rbiavg, statavg.idavg
				ORDER BY statavg.rbiavg DESC
				LIMIT 6;
--Same as above, but ready to insert into app
SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.rbiavg, statavg.idavg as playerid
				FROM
					batter_names
						as fullnames
					JOIN
						(SELECT
							baseball.batting.playerid as idavg,
							avg(baseball.batting.ab) as abavg,
							avg(baseball.batting.rbi) as rbiavg
							FROM baseball.batting
							WHERE baseball.batting.yearid >= ${minYear}
							AND baseball.batting.yearid <= ${maxYear}
							GROUP BY idavg)
						 as statavg
					ON fullnames.idall = statavg.idavg
					JOIN primary_position
				 ON statavg.idavg = primary_position.playerid
		   WHERE primary_position.pos = ${pos}
			AND statavg.abavg > 350
				GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, 	statavg.rbiavg, statavg.idavg
				ORDER BY statavg.rbiavg DESC
				LIMIT ${limit};
--Find runs plus rbi
SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.rrbiavg, statavg.idavg as playerid
				FROM
				--Get player full names from master table
					batter_names
						as fullnames
				--Get homer averages and constrain by year
					JOIN
						(SELECT
							baseball.batting.playerid as idavg,
							avg(baseball.batting.ab) as abavg,
							avg(baseball.batting.rbi+baseball.batting.r) as rrbiavg
							FROM baseball.batting
							WHERE baseball.batting.yearid >= 1800
							AND baseball.batting.yearid <= 2016
							GROUP BY idavg)
						 as statavg
					ON fullnames.idall = statavg.idavg
				--Get primary player positions
					JOIN primary_position
				 ON statavg.idavg = primary_position.playerid
		   WHERE primary_position.pos = 'OF'
			AND statavg.abavg > 350
				GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, 	statavg.rrbiavg, statavg.idavg
				ORDER BY statavg.rrbiavg DESC
				LIMIT 6;
--Same as above, but ready to insert into app
SELECT fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, statavg.rrbiavg, statavg.idavg as playerid
				FROM
					batter_names
						as fullnames
					JOIN
						(SELECT
							baseball.batting.playerid as idavg,
							avg(baseball.batting.ab) as abavg,
							avg(baseball.batting.rbi+baseball.batting.r) as rrbiavg
							FROM baseball.batting
							WHERE baseball.batting.yearid >= ${minYear}
							AND baseball.batting.yearid <= ${maxYear}
							GROUP BY idavg)
						 as statavg
					ON fullnames.idall = statavg.idavg

					JOIN primary_position
				 ON statavg.idavg = primary_position.playerid
		   WHERE primary_position.pos = ${pos}
			AND statavg.abavg > 350
				GROUP BY fullnames.namefirst, fullnames.namelast, primary_position.pos, statavg.abavg, 	statavg.rrbiavg, statavg.idavg
				ORDER BY statavg.rrbiavg DESC
				LIMIT ${limit};
