public without sharing class IDInformationController {
    
    @AuraEnabled
    public static List<Map<String, Object>> saveIDInformation(String idNumber) {
        //Parse Date
        Date dateOfBirth = date.parse(idNumber.substring(2, 4)+'/'+ idNumber.substring(4, 6)+'/19'+idNumber.substring(0, 2));
        //Get gender
        String gender = integer.valueof(idNumber.substring(6, 10)) < 5000 ? 'Female' : 'Male';
        //Get citzenship
        Boolean saCitizen = integer.valueof(idNumber.substring(10, 11)) == 0 ? true : false;
        
        //Get existing History record for counter
        list<ID_Search_History__c> SH=[select id,Search_Counter__c  from ID_Search_History__c where South_African_ID__c=:idNumber];
        Decimal Counter=0;
        if(SH.size()>0){
            Counter=SH[0].Search_Counter__c;
        }
        
        //Increment the counter
        Counter++;
        
        ID_Search_History__c idInfo = new ID_Search_History__c (
            South_African_ID__c  = idNumber,
            Date_of_Birth__c  = dateOfBirth,
            Gender__c  = gender,
            Citizen__c  = saCitizen,
            Search_Counter__c = Counter
        );
        
        List<Map<String, Object>> response =getPublicHolidays(String.valueOf(dateOfBirth.year())) ;
        upsert idInfo South_African_ID__c;
        return response;
    }
    
    // Method to call the Calendarific API and retrieve the list of holidays
    public static List<Map<String, Object>> getPublicHolidays(String year) {
        List<Map<String, Object>> publicHolidays = new List<Map<String, Object>>();
        String apiUrl = Label.calendarific + year;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('response.getBody() is '+response.getBody());
            Map<String, Object> responseMap = (Map<String, Object>) result.get('response');
            List<Object> holidaysList = (List<Object>) responseMap.get('holidays');
            
            for (Object holidayObj : holidaysList) {
                Map<String, Object> holidayMap = (Map<String, Object>) holidayObj;
                if(holidayMap.get('primary_type') == 'Public Holiday'){
                    Map<String, Object> dateMap = (Map<String, Object>) holidayMap.get('date');
                    Map<String, Object> datetimeMap = (Map<String, Object>) dateMap.get('datetime');
                    Map<String, Object> publicHoliday = new Map<String, Object>();
                    publicHoliday.put('name', holidayMap.get('name'));
                    publicHoliday.put('description', holidayMap.get('description'));
                    publicHoliday.put('date', dateMap.get('iso'));
                    publicHoliday.put('year', datetimeMap.get('year'));
                    publicHoliday.put('month', datetimeMap.get('month'));
                    publicHoliday.put('day', datetimeMap.get('day'));
                    publicHoliday.put('type', holidayMap.get('type'));
                    publicHoliday.put('primary_type', holidayMap.get('primary_type'));
                    publicHolidays.add(publicHoliday);
                }
            }
        }   
        return publicHolidays;
    }
    
    
}