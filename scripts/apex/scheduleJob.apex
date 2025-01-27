String jobName = 'Benchmark: Hourly';
String cron = '0 0 * * * ?';
System.Schedulable job = new BenchmarkSchedulable();
Id jobId = System.schedule(jobName, cron, job);
System.debug('Scheduled: ' + jobId);
