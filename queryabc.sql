SELECT abctype,
       totalbef,
       totalaft
FROM
  (SELECT count(abctype) AS totalbef,
          abctype,
          0 AS zerovalue
   FROM
     (SELECT inventory.itemnum,
             inventory.abctype,
             inventory.ccf,
             inventory.itemsetid
      FROM inventory
      INNER JOIN item item ON inventory.itemnum = item.itemnum
      AND inventory.itemsetid = item.itemsetid
      AND (inventory.abctype NOT IN('N',
                                    'NA')
           OR inventory.abctype IS NULL)
      LEFT OUTER JOIN invcost ON inventory.location = invcost.location
      AND inventory.itemnum = invcost.itemnum
      AND inventory.itemsetid = invcost.itemsetid
      AND inventory.siteid = invcost.siteid
      LEFT OUTER JOIN invlifofifocost ON inventory.location = invlifofifocost.location
      AND inventory.itemnum = invlifofifocost.itemnum
      AND inventory.itemsetid = invlifofifocost.itemsetid
      AND inventory.siteid = invlifofifocost.siteid ,
        (SELECT sum(coalesce(inventory.issueytd,0) * coalesce(invcost.lastcost,0)) AS tot_ytdissuecost,
                sum(coalesce(inventory.issueytd,0) * coalesce(invlifofifocost.unitcost,0)) AS tot_ytdlifofifocost
         FROM inventory
         INNER JOIN item item ON inventory.itemnum = item.itemnum
         AND inventory.itemsetid = item.itemsetid
         AND (inventory.abctype NOT IN('N',
                                       'NA')
              OR inventory.abctype IS NULL)
         LEFT OUTER JOIN invcost ON inventory.location = invcost.location
         AND inventory.itemnum = invcost.itemnum
         AND inventory.itemsetid = invcost.itemsetid
         AND inventory.siteid = invcost.siteid
         LEFT OUTER JOIN invlifofifocost ON inventory.location = invlifofifocost.location
         AND inventory.itemnum = invlifofifocost.itemnum
         AND inventory.itemsetid = invlifofifocost.itemsetid
         AND inventory.siteid = invlifofifocost.siteid
         WHERE 1=1
           AND ((inventory.location LIKE '%001%'))
           AND ((inventory.siteid LIKE '%001%')) )
      WHERE 1=1
        AND ((inventory.location LIKE '%001%'))
        AND ((inventory.siteid LIKE '%001%'))
        AND inventory.abctype IS NOT NULL
      GROUP BY inventory.itemnum,
               inventory.abctype,
               inventory.ccf,
               inventory.itemsetid
      ORDER BY abctype DESC)
   GROUP BY abctype
   ORDER BY abctype) firstt,

  (SELECT count(newabctype) AS totalaft,
          newabctype
   FROM
     (SELECT CASE
                 WHEN totalafter<=a_abcafter THEN 'A'
                 WHEN totalafter>b_abcafter THEN 'C'
                 ELSE 'B'
             END AS newabctype from
        (SELECT inv.itemnum, sum(inv2.svalue) AS totalafter
         FROM
           (SELECT (inventory.issueytd * (cast((coalesce(invcost.lastcost,0)+coalesce(invlifofifocost.unitcost,0)) AS decimal(10,5)))/(cast((coalesce(tot_ytdissuecost,0)+coalesce(tot_ytdlifofifocost,0)) AS decimal(10,5)))) AS svalue, inventory.itemnum, (coalesce(inventory.issueytd,0) * coalesce(invcost.lastcost,0)) AS ytd_issuecost
            FROM inventory
            INNER JOIN item item ON inventory.itemnum = item.itemnum
            AND inventory.itemsetid = item.itemsetid
            AND (inventory.abctype NOT IN('N', 'NA')
                 OR inventory.abctype IS NULL)
            LEFT OUTER JOIN invcost ON inventory.location = invcost.location
            AND inventory.itemnum = invcost.itemnum
            AND inventory.itemsetid = invcost.itemsetid
            AND inventory.siteid = invcost.siteid
            LEFT OUTER JOIN invlifofifocost ON inventory.location = invlifofifocost.location
            AND inventory.itemnum = invlifofifocost.itemnum
            AND inventory.itemsetid = invlifofifocost.itemsetid
            AND inventory.siteid = invlifofifocost.siteid ,
              (SELECT sum(coalesce(inventory.issueytd,0) * coalesce(invcost.lastcost,0)) AS tot_ytdissuecost, sum(coalesce(inventory.issueytd,0) * coalesce(invlifofifocost.unitcost,0)) AS tot_ytdlifofifocost
               FROM inventory
               INNER JOIN item item ON inventory.itemnum = item.itemnum
               AND inventory.itemsetid = item.itemsetid
               AND (inventory.abctype NOT IN('N', 'NA')
                    OR inventory.abctype IS NULL)
               LEFT OUTER JOIN invcost ON inventory.location = invcost.location
               AND inventory.itemnum = invcost.itemnum
               AND inventory.itemsetid = invcost.itemsetid
               AND inventory.siteid = invcost.siteid
               LEFT OUTER JOIN invlifofifocost ON inventory.location = invlifofifocost.location
               AND inventory.itemnum = invlifofifocost.itemnum
               AND inventory.itemsetid = invlifofifocost.itemsetid
               AND inventory.siteid = invlifofifocost.siteid
               WHERE 1=1
                 AND ((inventory.location LIKE '%001%'))
                 AND ((inventory.siteid LIKE '%001%')) )
            WHERE 1=1
              AND ((inventory.location LIKE '%001%'))
              AND ((inventory.siteid LIKE '%001%'))
            GROUP BY inventory.itemnum, inventory.issueytd, invcost.lastcost, invlifofifocost.unitcost, tot_ytdissuecost, tot_ytdlifofifocost
            ORDER BY ytd_issuecost DESC) inv,
           (SELECT (inventory.issueytd * (cast((coalesce(invcost.lastcost,0)+coalesce(invlifofifocost.unitcost,0)) AS decimal(10,5)))/(cast((coalesce(tot_ytdissuecost,0)+coalesce(tot_ytdlifofifocost,0)) AS decimal(10,5)))) AS svalue, inventory.itemnum, (coalesce(inventory.issueytd,0) * coalesce(invcost.lastcost,0)) AS ytd_issuecost
            FROM inventory
            INNER JOIN item item ON inventory.itemnum = item.itemnum
            AND inventory.itemsetid = item.itemsetid
            AND (inventory.abctype NOT IN('N', 'NA')
                 OR inventory.abctype IS NULL)
            LEFT OUTER JOIN invcost ON inventory.location = invcost.location
            AND inventory.itemnum = invcost.itemnum
            AND inventory.itemsetid = invcost.itemsetid
            AND inventory.siteid = invcost.siteid
            LEFT OUTER JOIN invlifofifocost ON inventory.location = invlifofifocost.location
            AND inventory.itemnum = invlifofifocost.itemnum
            AND inventory.itemsetid = invlifofifocost.itemsetid
            AND inventory.siteid = invlifofifocost.siteid ,
              (SELECT sum(coalesce(inventory.issueytd,0) * coalesce(invcost.lastcost,0)) AS tot_ytdissuecost, sum(coalesce(inventory.issueytd,0) * coalesce(invlifofifocost.unitcost,0)) AS tot_ytdlifofifocost
               FROM inventory
               INNER JOIN item item ON inventory.itemnum = item.itemnum
               AND inventory.itemsetid = item.itemsetid
               AND (inventory.abctype NOT IN('N', 'NA')
                    OR inventory.abctype IS NULL)
               LEFT OUTER JOIN invcost ON inventory.location = invcost.location
               AND inventory.itemnum = invcost.itemnum
               AND inventory.itemsetid = invcost.itemsetid
               AND inventory.siteid = invcost.siteid
               LEFT OUTER JOIN invlifofifocost ON inventory.location = invlifofifocost.location
               AND inventory.itemnum = invlifofifocost.itemnum
               AND inventory.itemsetid = invlifofifocost.itemsetid
               AND inventory.siteid = invlifofifocost.siteid
               WHERE 1=1
                 AND ((inventory.location LIKE '%001%'))
                 AND ((inventory.siteid LIKE '%001%')) )
            WHERE 1=1
              AND ((inventory.location LIKE '%001%'))
              AND ((inventory.siteid LIKE '%001%'))
            GROUP BY inventory.itemnum, inventory.issueytd, invcost.lastcost, invlifofifocost.unitcost, tot_ytdissuecost, tot_ytdlifofifocost
            ORDER BY ytd_issuecost DESC) inv2
         WHERE inv.svalue<=inv2.svalue
           OR inv.itemnum=inv2.itemnum
         GROUP BY inv.itemnum, inv.svalue
         ORDER BY inv.svalue DESC) cumultable,
        (SELECT *
         FROM
           (SELECT sum(replace(maxvars.varvalue,',','')) AS a_abcafter
            FROM maxvars
            WHERE maxvars.varname IN ('A_BREAKPOINT')
              AND maxvars.orgid = '01' ) ,
           (SELECT sum(replace(maxvars.varvalue,',','')) AS b_abcafter
            FROM maxvars maxvars
            WHERE maxvars.varname IN ('A_BREAKPOINT',
                                      'B_BREAKPOINT')
              AND maxvars.orgid = '01' ) ,
           (SELECT sum(replace(maxvars.varvalue,',','')) AS c_abcafter
            FROM maxvars maxvars
            WHERE maxvars.varname IN ('A_BREAKPOINT',
                                      'B_BREAKPOINT',
                                      'C_BREAKPOINT')
              AND maxvars.orgid = '01' )))
   GROUP BY newabctype) secondt
WHERE abctype=newabctype
UNION ALL
SELECT abctype,
       count(itemnum) AS totalbef,
       0 AS totalaft
FROM
  (SELECT inventory.itemnum,
          inventory.abctype,
          inventory.ccf,
          inventory.itemsetid
   FROM inventory
   INNER JOIN item item ON inventory.itemnum = item.itemnum
   AND inventory.itemsetid = item.itemsetid
   AND (inventory.abctype NOT IN('N',
                                 'NA')
        OR inventory.abctype IS NULL)
   LEFT OUTER JOIN invcost ON inventory.location = invcost.location
   AND inventory.itemnum = invcost.itemnum
   AND inventory.itemsetid = invcost.itemsetid
   AND inventory.siteid = invcost.siteid
   LEFT OUTER JOIN invlifofifocost ON inventory.location = invlifofifocost.location
   AND inventory.itemnum = invlifofifocost.itemnum
   AND inventory.itemsetid = invlifofifocost.itemsetid
   AND inventory.siteid = invlifofifocost.siteid ,
     (SELECT sum(coalesce(inventory.issueytd,0) * coalesce(invcost.lastcost,0)) AS tot_ytdissuecost,
             sum(coalesce(inventory.issueytd,0) * coalesce(invlifofifocost.unitcost,0)) AS tot_ytdlifofifocost
      FROM inventory
      INNER JOIN item item ON inventory.itemnum = item.itemnum
      AND inventory.itemsetid = item.itemsetid
      AND (inventory.abctype NOT IN('N',
                                    'NA')
           OR inventory.abctype IS NULL)
      LEFT OUTER JOIN invcost ON inventory.location = invcost.location
      AND inventory.itemnum = invcost.itemnum
      AND inventory.itemsetid = invcost.itemsetid
      AND inventory.siteid = invcost.siteid
      LEFT OUTER JOIN invlifofifocost ON inventory.location = invlifofifocost.location
      AND inventory.itemnum = invlifofifocost.itemnum
      AND inventory.itemsetid = invlifofifocost.itemsetid
      AND inventory.siteid = invlifofifocost.siteid
      WHERE 1=1
        AND ((inventory.location LIKE '%001%'))
        AND ((inventory.siteid LIKE '%001%')) )
   WHERE 1=1
     AND ((inventory.location LIKE '%001%'))
     AND ((inventory.siteid LIKE '%001%'))
     AND inventory.abctype IS NULL
   GROUP BY inventory.itemnum,
            inventory.abctype,
            inventory.ccf,
            inventory.itemsetid)
GROUP BY abctype
ORDER BY abctype;