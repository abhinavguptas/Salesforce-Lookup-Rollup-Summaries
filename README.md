# What problem are we trying to solve ?

Rollup summary fields are pretty common requirement in force.com customizations and app development. Rollups are easy to create on master-detail relationships as they are available as a field type. But on certain limits/situations we need to write apex code for rolling up the child information for common aggregations like COUNT, SUM, AVG, MAX/MIN etc, some of these limitations are
 * [Only 10 rollup summary fields allowed per object on master detail relationships](http://ap1.salesforce.com/help/doc/en/limits.htm#CustomFieldLimitDetails)
 * Rollup child sobject records part of a lookup relationship. Native rollup summary fields are not available on LOOKUP relationships.

The 'USUAL' approach to handle this limitation is to either
 * Write trigger on various DML(Create, Update, Delete/Undelete) events on child sobject. These trigger either manually aggregated the information via Apex or used SOQL Aggregate queries for the same.   
 * Write some batch/scheduled apex to perform this nightly.

## Problem in USUAL approach ?
Most of the times the rollup code/logic is pretty similar. Bigger problem happens sometimes in following situation
 * Client asked for a rollup field on lookup
   * Developer added a trigger on child object with required events
 * After few weeks client asked for another such rollup field on the same lookup object.
   * Developer tried not to disturb logic of existing trigger and added new trigger on same object for addressing the requirement

 This approach tends to burst when there are many such code driven lookup fields added over the time, and multiple developers are working on same codebase. Its pretty easy to run close to governor limits, as similar aggregations are happening multiple times separately in different triggers, those governor limits most probably would be
  - Number of SOQL queries
  - Number of records fetched
  - Script statements consumed

## How this lib ('LREngine') solves the problem ?
This library contains one single class called "LREngine" i.e. "L"ookup "R"ollup Engine, which 
 * Performs rollup on multiple such fields in a single aggregate soql query. 
 * Allows easy addition/removal of new fields to rollup as requirement changes over the span of time.
 * Developer needs to write only a single trigger for multiple rollup fields.
 * Allows developer to filter the child records getting rolled up, just like standard rollup summary fields

### Using LREngine in Triggers
Using LREngine in trigger is fairly simple as indicated in the code snippet, developer just needs to take care of checks related to business requirements and call the LREngine. 

Please note : Make sure you have trapped all create/delete/undelete/update events on child object to make sure all calculations are correct.

```java
trigger OppRollup on Opportunity (after insert, after update, 
                                        after delete, after undelete) {
      // modified objects whose parent records should be updated
     Opportunity[] objects = null;   

     if (Trigger.isDelete) {
         objects = Trigger.old;
     } else {
        /*
            Handle any filtering required, specially on Trigger.isUpdate event. If the rolled up fields
            are not changed, then please make sure you skip the rollup operation.
            We are not adding that for sake of similicity of this illustration.
        */ 
        objects = Trigger.new;
     }

     /*
      First step is to create a context for LREngine, by specifying parent and child objects and
      lookup relationship field name
     */
     LREngine.Context ctx = new LREngine.Context(Account.SobjectType, // parent object
                                            Opportunity.SobjectType,  // child object
                                            Schema.SObjectType.Opportunity.fields.AccountId // relationship field name
                                            );     
     /*
      Next, one can add multiple rollup fields on the above relationship. 
      Here specify 
       1. The field to aggregate in child object
       2. The field to which aggregated value will be saved in master/parent object
       3. The aggregate operation to be done i.e. SUM, AVG, COUNT, MIN/MAX
     */
     ctx.add(
            new LREngine.RollupSummaryField(
                                            Schema.SObjectType.Account.fields.AnnualRevenue,
                                            Schema.SObjectType.Opportunity.fields.Amount,
                                            LREngine.RollupOperation.Sum 
                                         )); 
     ctx.add(
            new LREngine.RollupSummaryField(
                                            Schema.SObjectType.Account.fields.SLAExpirationDate__c,
                                               Schema.SObjectType.Opportunity.fields.CloseDate,
                                               LREngine.RollupOperation.Max
                                         ));                                       
	 
     /* 
      Calling rollup method returns in memory master objects with aggregated values in them. 
      Please note these master records are not persisted back, so that client gets a chance 
      to post process them after rollup
      */ 
     Sobject[] masters = LREngine.rollUp(ctx, objects);    

     // Persiste the changes in master
     update masters;
}
```

### Using LREngine in Batch/Scheduled/etc Apex 
If we are not using triggers for some reason to aggregate the detail records. In that case Batch or Scheduled Apex is used on some occasions. Calling LREngine is fairly easy, once you have master record ids in hand just call the API as indicated in the code snippet below:

```java
LREngine.Context ctx = // create context with required roll up summary fields as shown in above code snippet
Set<Id> masterRecordIds = // master record ids as per the business logic
Sobject[] masters = LREngine.rollUp(ctx, masterRecordIds);   
```

### Adding some conditional filtering to the rollup operation
Doing this is pretty easy, just add the condition in the Context constructor as shown below 
```java
LREngine.Context ctx = new LREngine.Context(Account.SobjectType, 
	                        Opportunity.SobjectType, 
	                        Schema.SObjectType.Opportunity.fields.AccountId,
	                        'Amount > 200' // filter out any opps with amount less than 200
	                        );

```
# Installing LREngine
This is fairly simple, just copy the LREngine.cls (Core logic) and TestLREngine.cls(Test case + code coverage) to help. 

# Important points
 * Using LREngine is not recommended when number of child records associated with master records are too much. Because salesforce limit on "Total number of records retrieved by SOQL queries" is 50,000 as of now. 
 * LREngine doesn't persists changes back to master records after rollup. This gives client code to perform any further calculations, but please make sure you call UPDATE on master records to persist the changes.
