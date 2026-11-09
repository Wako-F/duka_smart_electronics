# Duka Smart Electronics Retail Analytics

This project analyses the Duka Smart Electronics sales data supplied with the assignment, using PostgreSQL. It contains the database setup scripts, answers to all 46 assignment questions, and a validation script to check the results.

## Files

- `scripts/01_create_database.sql` to `scripts/05_verify_data.sql`: the original supplied setup and verification scripts, unchanged.
- `schema.sql`: an alternative copy of the table definitions in `scripts/02_create_tables.sql`.
- `queries.sql`: answers to Q1 to Q46, including the Q43 view and Q44 function.
- `insights.md`: eight insights drawn from the results.

## Setup

You need PostgreSQL 14 or newer. Run the scripts below in order from the project folder. Script 01 runs against `postgres`, and the rest run against `retail_analytics`. If `psql` is on your PATH, you can use `psql` instead of the full path.

```powershell
& 'C:/Program Files/PostgreSQL/18/bin/psql.exe' -U postgres -d postgres -v ON_ERROR_STOP=1 -f scripts/01_create_database.sql
& 'C:/Program Files/PostgreSQL/18/bin/psql.exe' -U postgres -d retail_analytics -v ON_ERROR_STOP=1 -f scripts/02_create_tables.sql
& 'C:/Program Files/PostgreSQL/18/bin/psql.exe' -U postgres -d retail_analytics -v ON_ERROR_STOP=1 -f scripts/03_insert_customers.sql
& 'C:/Program Files/PostgreSQL/18/bin/psql.exe' -U postgres -d retail_analytics -v ON_ERROR_STOP=1 -f scripts/04_insert_orders.sql
& 'C:/Program Files/PostgreSQL/18/bin/psql.exe' -U postgres -d retail_analytics -v ON_ERROR_STOP=1 -f scripts/05_verify_data.sql
```

Enter your PostgreSQL password when prompted. 

Notes:
- Use either `scripts/02_create_tables.sql` or `schema.sql` to create the tables, not both. The original script is the recommended one.
- If your database is not on the default port 5432, add `-h <host> -p <port>` to each command.
- In pgAdmin, create a database called `retail_analytics` and run scripts 02 to 05 in it. Script 01 only works in `psql`.

## Running the queries

```powershell
& 'C:/Program Files/PostgreSQL/18/bin/psql.exe' -U postgres -d retail_analytics -v ON_ERROR_STOP=1 -f queries.sql
```

Each `-- Q1` to `-- Q46` section answers the matching assignment question. Q43 and Q44 create a view and a function.

