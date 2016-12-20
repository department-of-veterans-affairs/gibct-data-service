SELECT csv_files.* FROM csv_files 
	INNER JOIN (
		SELECT cf.csv_type as ctype, MAX(cf.created_at) as max_ct FROM csv_files cf 
  		WHERE cf.result = 'Successful' 
  		GROUP BY cf.csv_type) md
		ON md.ctype =  csv_files.csv_type
		WHERE md.max_ct=csv_files.created_at;