@isTest
private class CurrencyManagementTest {
    @testSetup static void setupCustomSettings() {
        Nexthink_Custom_Settings__c ncs = new Nexthink_Custom_Settings__c(SetupOwnerId=Userinfo.getUserId());
        insert ncs;
    }

    @isTest
    static void testCurrencyManagementFromCorporate() {
        NexthinkProvider np = NexthinkProvider.getInstance();
        Test.startTest();

        Map<String, Object> accountProperties = new Map<String, Object>();
        accountProperties.put('Name', 'Customer1');
        accountProperties.put('Type', 'Customer');
        accountProperties.put('Industry', 'Services');
        accountProperties.put('CurrencyIsoCode', 'USD');
        accountProperties.put('Country__c', 'Switzerland');
        accountProperties.put('BillingCountry', 'Switzerland');
        accountProperties.put('BillingState', 'Vaud');
        Account customer = np.createAccount(accountProperties);
        accountProperties.put('Name', 'Partner1');
        accountProperties.put('Type', 'Partner');
        accountProperties.put('CreditLine__c', 1);
        accountProperties.put('Industry', 'Technology');
        Account partner = np.createAccount(accountProperties);

        Map<String, Object> opportunityProperties = new Map<String, Object>();
        opportunityProperties.put('Name', customer.Name + '_Project1_New Customer');
        opportunityProperties.put('AccountId', customer.Id);
        opportunityProperties.put('Amount', 200);
        opportunityProperties.put('CloseDate', Date.today().addDays(31));
        opportunityProperties.put('StageName', 'Pre Qualify');
        opportunityProperties.put('CurrencyIsoCode', 'USD');
        opportunityProperties.put('LeadSource', 'Sales - Nexthink Direct');
        opportunityProperties.put('Partner_Lookup__c', partner.Id);
        Opportunity o = np.createOpportunity(opportunityProperties);

        Decimal eurAmount = CurrencyManagement.convertFromCorporateCurrency('EUR', o.Amount, o.CloseDate);
        Decimal usdAmount = CurrencyManagement.convertToCorporateCurrency('EUR', eurAmount, o.CloseDate);
        System.assertEquals(eurAmount, CurrencyManagement.convertFromCorporateCurrency('EUR', usdAmount, o.CloseDate));
        System.assertEquals(usdAmount, o.Amount);

        Test.StopTest();
    }

    @isTest
    static void testCurrencyManagementToCorporate() {
        NexthinkProvider np = NexthinkProvider.getInstance();
        Test.startTest();

        Map<String, Object> accountProperties = new Map<String, Object>();
        accountProperties.put('Name', 'Customer1');
        accountProperties.put('Type', 'Customer');
        accountProperties.put('Industry', 'Services');
        accountProperties.put('CurrencyIsoCode', 'USD');
        accountProperties.put('Country__c', 'Switzerland');
        accountProperties.put('BillingCountry', 'Switzerland');
        accountProperties.put('BillingState', 'Vaud');
        Account customer = np.createAccount(accountProperties);
        accountProperties.put('Name', 'Partner1');
        accountProperties.put('Type', 'Partner');
        accountProperties.put('CreditLine__c', 1);
        accountProperties.put('Industry', 'Technology');
        Account partner = np.createAccount(accountProperties);

        Map<String, Object> opportunityProperties = new Map<String, Object>();
        opportunityProperties.put('Name', customer.Name + '_Project1_New Customer');
        opportunityProperties.put('AccountId', customer.Id);
        opportunityProperties.put('Amount', 200);
        opportunityProperties.put('CloseDate', Date.today().addDays(31));
        opportunityProperties.put('StageName', 'Pre Qualify');
        opportunityProperties.put('CurrencyIsoCode', 'EUR');
        opportunityProperties.put('LeadSource', 'Sales - Nexthink Direct');
        opportunityProperties.put('Partner_Lookup__c', partner.Id);
        Opportunity o = np.createOpportunity(opportunityProperties);

        Decimal usdAmount = CurrencyManagement.convertToCorporateCurrency(o.CurrencyIsoCode, o.Amount, o.CloseDate);
        Decimal eurAmount = CurrencyManagement.convertFromCorporateCurrency('EUR', usdAmount, o.CloseDate);
        System.assertEquals(usdAmount.round(), (CurrencyManagement.convertToCorporateCurrency('EUR', eurAmount, o.CloseDate)).round());
        System.assertEquals(eurAmount.round(), o.Amount);

        Test.StopTest();
    }
}