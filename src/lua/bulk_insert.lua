#!/usr/bin/env sysbench
-- -------------------------------------------------------------------------- --
-- Bulk insert benchmark: do multi-row INSERTs concurrently in --num-threads
-- threads with each thread inserting into its own table. The number of INSERTs
-- executed by each thread is controlled by either --max-time or --max-requests.
-- -------------------------------------------------------------------------- --

cursize=0

function thread_init()
   drv = sysbench.sql.driver()
   con = drv:connect()
end

function prepare()
   local i

   local drv = sysbench.sql.driver()
   local con = drv:connect()

   for i = 1, num_threads do
      print("Creating table 'sbtest" .. i .. "'...")
      con:query(string.format([[
        CREATE TABLE IF NOT EXISTS sbtest%d (
          id INTEGER NOT NULL,
          k INTEGER DEFAULT '0' NOT NULL,
          PRIMARY KEY (id))]], i))
   end
end

function event()
   if (cursize == 0) then
      con:bulk_insert_init("INSERT INTO sbtest" .. thread_id+1 .. " VALUES")
   end

   cursize = cursize + 1

   con:bulk_insert_next("(" .. cursize .. "," .. cursize .. ")")
end

function thread_done(thread_9d)
   con:bulk_insert_done()
end

function cleanup()
   local i

   local drv = sysbench.sql.driver()
   local con = drv:connect()

   for i = 1, num_threads do
      print("Dropping table 'sbtest" .. i .. "'...")
      con:query("DROP TABLE IF EXISTS sbtest" .. i )
   end
end
