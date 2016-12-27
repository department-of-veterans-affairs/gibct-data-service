SELECT id FROM versions
  INNER JOIN 
    (SELECT max(created_at) AS max_created_at FROM versions) AS v
    ON v.max_created_at=created_at
  WHERE production=true;