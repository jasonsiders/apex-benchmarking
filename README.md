# `apex-benchmarking`

Many Salesforce orgs struggle with performance. Whether you’re an admin, developer, or end user, you’ve probably spent too much time staring at a spinning wheel or waiting for save operations to complete. And if you’re “lucky,” you’ve likely seen this error a time or two:

```sh
System.LimitException: Apex CPU time limit exceeded
```

As Salesforce Developers, making sure our automations and processes run as efficiently as possible is a top priority. Yet, the Salesforce platform doesn't offer anything to measure performance in a way that’s automated, consistent, and repeatable.

`apex-benchmarking` aims to bridge this gap. The framework provides Salesforce Developers an automated way to measure the performance of critical automations and processes over time.

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

Once the package is installed, follow these steps to get started:

1. Define "Benchmark Jobs" to specify the actions you want to measure.
2. Schedule the Benchmark Jobs to run at regular intervals.
3. Monitor and analyze the resulting `Benchmark__c` records to track performance.

### Creating Benchmark Jobs

Each run of the Benchmark Job creates a `Benchmarkable` instance, using the Apex Class name specified in the `BenchmarkJobSetting__mdt.ApexClass__c` field. The framework uses this class to setup and execute the logic to be benchmarked, and then stores details about the run in the `Benchmark__c` custom object.

To create your own test cases for benchmarking, follow these two simple steps:

#### Step 1: Create a `Benchmarkable` Instance

The `Benchmarkable` interface requires two methods:

- `void setup()`: Handles any pre-processing needed for the test case.
- `void benchmark()`: Executes the specific action to be measured by the Benchmark Job.

For accurate results, the `benchmark()` method should focus solely on the action being measured. Avoid including unnecessary code—use the `setup()` method for any pre-processing instead.

Here is an example implementation that measures the time it takes to create a `Contact` record.

```java
public without sharing class BenchmarkContactCreate implements Benchmarkable {
  private Contact contact;

  public void setup() {
    // Insert an Account
    Account acc = new Account(Name = 'Test Account');
    Database.insert(acc, System.AccessLevel.SYSTEM_MODE);
    // Create a Contact, to be inserted later...
    this.contact = new Contact(AccountId = acc?.Id, FirstName = 'John', LastName = 'Doe');
  }

  public void benchmark() {
    // Insert the aforementioned Contact
    Database.insert(this.contact, System.AccessLevel.SYSTEM_MODE);
  }
}
```

#### Step 2: Create a `BenchmarkJobSetting__mdt` Record

Every Benchmark Job requires a corresponding `BenchmarkJobSetting__mdt` record. This custom metadata type defines the configuration for the job:

![A sample BenchmarkJobSetting__mdt record](media/benchmark_job_settings.png)

Each record should be linked to the `Benchmarkable` class you created in [Step 1](#step-1-create-a-benchmarkable-instance) via the _Apex Class_ field.

You can also include optional details about the job, such as the `SObjectType` and the type of `Operation` being performed or benchmarked. These details will be recorded in the resulting `Benchmark__c` records and can be helpful for reporting.

You can also use this record to configure where and when Benchmark jobs should run:

- **Active:** If unchecked, the specified Benchmark job will not run. If checked, the job will run, as long as it’s eligible in the current environment (see below).
- **Excluded Sandbox(es):** A comma-separated list of sandbox names (e.g., `full`, `partial`, `uat`). The specified Benchmark job will not run in these sandboxes.
- **Run In Production?:** If checked, the Benchmark job will run in Production (and Developer Edition) orgs. By default, this is `false`.

> _:rotating_light: **IMPORTANT**: Each Benchmark Job is rolled back at the end of the transaction. However, some actions (such as "deliver immediately" Platform Events, API calls, etc.) cannot be rolled back. Use caution if you choose to override this setting._

### Schedule Recurring Benchmark Jobs

To schedule your benchmark jobs to run at regular intervals, use the included `BenchmarkSchedulable` class.

This class will execute any Benchmark Jobs configured in the `BenchmarkJobSetting__mdt` table, as long as they are active and eligible to run in the current environment.

For example, this anonymous Apex script schedules benchmark jobs to run at the top of each hour:

```java
String jobName = 'Benchmark: Hourly';
String hourlyCron = '0 0 * * * ?';
System.Schedulable job = new BenchmarkSchedulable();
Id jobId = System.schedule(jobName, hourlyCron, job);
System.debug('Scheduled: ' + jobId);
```

### Monitoring

The results of each benchmark job are recorded in the `Benchmark__c` custom object. You can run reports on this object to monitor the performance of specific benchmarks over time.

![An example of a Benchmark record](media/benchmark_record.png)
