# What problem are we trying to solve ?

Rollup summary fields are pretty common requirement in force.com customizations and app development. Rollups are easy to create on master-detail relationships as they are available as a field type. But on certain situations we need to write code(Trigger/Apex/Batch) for rolling up the child information for common aggregations like COUNT, SUM, AVG, MAX/MIN etc, some of these situations are
 * [Only 10 rollup summary fields allowed per object on master detail relationships](http://ap1.salesforce.com/help/doc/en/limits.htm#CustomFieldLimitDetails)
 * Rollup child sobject records part of a lookup relationship.

# How we solved this problem in past (Classic approach) ?

Such manual aggregations on parent fields are usually done by Triggers on CUD(Create, Update, Delete) events. These trigger either manually aggregated the information via Apex or used SOQL Aggregate queries for the same. 

## Problem in using classic approach
Most of the times the rollup code/logic is pretty similar. Bigger problem happens sometimes in following situation
 * Client asked for a rollup field on lookup
 	* Developer added a trigger on child object with required events
 * After few weeks client asked for another such rollup field on the same lookup object.
 	* Developer tried not to disturb logic of existing trigger and added new trigger on same object for addressing the requirement

 This approach tends to burst when there are many such code driven lookup fields added over the time, and multiple developers are working on same codebase. Its pretty easy to run close to governor limits, as similar aggregations are happening multiple times separately in different triggers, those governor limits most probably would be
  - Number of SOQL queries
  - Number of records fetched
  - Script statements consumed

## How this Open Source lib solves the problem
This library contains one single class called "LREngine" i.e. "L"ookup "R"ollup Engine, which 
 * Performs rollup on multiple such fields in a single aggregate soql query. 
 * Allows easy addition/removal of new fields to rollup as requirement changes over the span of time.
 * Developer needs to write only a single trigger for multiple rollup fields.
 * Allows developer to filter the child records getting rolled up, just like standard rollup summary fields



