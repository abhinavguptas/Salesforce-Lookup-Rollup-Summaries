public with sharing class CurrencyManagement {
    private static Map<ID, DatedConversionRate> dcrMap;

    public static Decimal convertToCorporateCurrency(String currencyIso, Decimal currencyVal, Date currencyDate) {
        Decimal res;
        if (currencyIso != null && currencyVal != null) {
            if (dcrMap == null) {
                dcrMap = new Map<ID,DatedConversionRate> ([SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate]);
            }
            for (DatedConversionRate dcr: dcrMap.values()) {
                if (dcr.isoCode != currencyIso)                                         continue;   // look for a match in table against input currency
                if (currencyDate < dcr.startDate || currencyDate >= dcr.nextStartDate)  continue;   // not in the range of effective dates
                res =  currencyVal / dcr.conversionRate;
                break;
            }
        }
        return res;
    }

    public static Decimal convertFromCorporateCurrency(String currencyIso, Decimal currencyVal, Date currencyDate) {
        Decimal res;
        if (currencyIso != null && currencyVal != null) {
            if (dcrMap == null) {
                dcrMap = new Map<ID,DatedConversionRate> ([SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate]);
            }
            for (DatedConversionRate dcr: dcrMap.values()) {
                if (dcr.isoCode != currencyIso)                                         continue;   // look for a match in table against input currency
                if (currencyDate < dcr.startDate || currencyDate >= dcr.nextStartDate)  continue;   // not in the range of effective dates
                res =  currencyVal * dcr.conversionRate;
                break;
            }
        }
        return res;
    }
}