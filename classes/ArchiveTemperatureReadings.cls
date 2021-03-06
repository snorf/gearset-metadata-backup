/**
 * Created by Johan Karlsteen on 2017-10-08.
 */

global class ArchiveTemperatureReadings implements Schedulable {
    public static void start(Integer perDay){
        Integer hour = 0;
        for(Integer i=1; i<=perDay; i++){
            ArchiveTemperatureReadings atr = new ArchiveTemperatureReadings();
            String schedule = '0 0 ' + hour + ' * 1-12 ? *';
            System.schedule('ArchiveTemperatureReadings (' + hour + ') #'+i+' '+System.now(), schedule, atr);
            hour = hour+(24/perDay);
        }
    }

    global void execute(SchedulableContext ctx) {
        doWork();
    }
    
    public void doWork() {
        Datetime lastReading = [SELECT DeviceId__c, Temperature__c, ts__c FROM Fridge_Reading_History__b LIMIT 1].ts__c;
        for(List<Fridge_Reading_Daily_History__c> toArchive : [SELECT Id,ts__c,DeviceId__c,Door__c,Temperature__c,Humidity__c
                                                                FROM Fridge_Reading_Daily_History__c]) {
            List<Fridge_Reading_History__b> updates = new List<Fridge_Reading_History__b>();
            for (Fridge_Reading_Daily_History__c event : toArchive) {
                Fridge_Reading_History__b frh = new Fridge_Reading_History__b();
                frh.DeviceId__c = event.DeviceId__c;
                frh.Door__c = event.Door__c;
                frh.Humidity__c = event.Humidity__c;
                frh.Temperature__c = event.Temperature__c;
                frh.ts__c = event.ts__c;
                updates.add(frh);
            }
            Database.insertImmediate(updates);
        }
    }
}