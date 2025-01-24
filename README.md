# `apex-benchmarking`

:warning: TODO! :warning:

---

## Getting Started

`apex-benchmarking` is available as an unlocked package. You can find all package version ids catalogued in the repo's [Releases](https://github.com/jasonsiders/apex-benchmarking/releases/).

### Installation

Run the following command, replacing `<<package_version_id>>` with your desired package ID (which begins with `04t`):

```sh
sf package install --package <<package_version_id>> --wait 10
```

### Provisioning

The results of Benchmark jobs are stored in a custom object, called `Benchmark__c`. To be able to view these records, users must have access to the object.

You can provision access to this object via one of the included permission sets:

- `BenchmarkAccess`: Gives **read-only** access to _Benchmark_ records.
- `BenchmarkAdministrator`: Gives **full** access to _Benchmark_ records.

Run the following command to assign yourself the appropriate permissions:

```sh
sf org assign permset --name BenchmarkAdministrator
```

---

## Usage

Setting up your own benchmarking test cases is a relatively simple process for a developer to perform.

### Creating `Benchmarkable` Instances

:warning: TODO! :warning:

### Configuring `BenchmarkJobSetting__mdt` Records

:warning: TODO! :warning:

### Scheduling Recurring Benchmark Jobs

To schedule your benchmark jobs to run at a regular interval, use the included `BenchmarkSchedulable` class.

For example, this anonymous apex script schedules benchmark jobs to run at the top of each hour:

```java
String jobName = 'Benchmark: Hourly';
String hourlyCron = '0 0 * * * ?';
System.Schedulable job = new BenchmarkSchedulable();
Id jobId = System.schedule(jobName, hourlyCron, job);
System.debug('Scheduled: ' + jobId);
```
