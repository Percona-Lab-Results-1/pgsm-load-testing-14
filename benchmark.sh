#!/bin/bash

# Set the database connection parameters
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="your_database"
DB_USER="your_username"
DB_PASSWORD="your_password"

# Set the number of threads, total transactions, and duration
THREADS=10
TRANSACTIONS=1000
DURATION=300

# Set the sysbench parameters
SYSBENCH_SCRIPT="sysbench.lua"
SYSBENCH_TABLES="your_table1,your_table2"
SYSBENCH_ROWS=10000

# Set the pgbench parameters
PG_USER="your_pgbench_user"
PG_SCALE=100
PG_DURATION=$DURATION

# Create the monitoring extension in the database
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS pg_stat_monitor;"

# Load test using sysbench
sysbench --threads=$THREADS --time=$DURATION --db-driver=pgsql --pgsql-host=$DB_HOST --pgsql-port=$DB_PORT --pgsql-db=$DB_NAME --pgsql-user=$DB_USER --pgsql-password=$DB_PASSWORD --pgsql-ignore-errors=ALL --lua-script=$SYSBENCH_SCRIPT --tables=$SYSBENCH_TABLES --table-size=$SYSBENCH_ROWS --events=0 --report-interval=1 run

# Load test using pgbench
pgbench -h $DB_HOST -p $DB_PORT -U $PG_USER -d $DB_NAME -i -s $PG_SCALE
pgbench -h $DB_HOST -p $DB_PORT -U $PG_USER -d $DB_NAME -c $THREADS -T $PG_DURATION -M prepared -P 5 -f pgbench_script.sql -j $THREADS -n -r -C -q

# Print the benchmark results from pg_stat_monitor
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT * FROM pg_stat_monitor;"

