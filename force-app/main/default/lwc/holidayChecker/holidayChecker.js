import { LightningElement } from 'lwc';
import setSearchResult from '@salesforce/apex/IDInformationController.saveIDInformation';

export default class HolidayChecker extends LightningElement {
    idNumber = '';
    error = '';
    inputError;
    inputSuccess;
    publicHolidays;
    isLoading=false;

    columns = [
        { label: 'Holiday Name', fieldName: 'name' },
        { label: 'Description', fieldName: 'description' },
        { label: 'Date', fieldName: 'date', type: 'date',typeAttributes:{
            weekday: "long",
            year: "numeric",
            month: "long",
            day: "2-digit"
        } },
    ];

    handleIdNumberChange(event) {
        this.idNumber = event.target.value;
    }

    handleSearch() {
        this.isLoading=true;
        if (this.validateID(this.idNumber)) {
            this.inputError=false;
            this.saveSearchData(this.idNumber);
        }else{
            this.inputError=true;
            this.inputSuccess=false;
            this.publicHolidays=undefined;
            this.isLoading=false;
        }
    }


    saveSearchData(idNumber) {
        setSearchResult({ idNumber: this.idNumber })
            .then((result) => {
                this.error = undefined;
                this.publicHolidays=result;
                this.isLoading=false;
                this.inputSuccess=true;
            })
            .catch((error) => {
                this.error = error;
                this.isLoading=false;
            });
    }

    validateID(idNumber) {
        if (idNumber.length !== 13) {
            return false;
        }
        //found this regex from https://codepen.io/foxbeefly/pen/yYwgwd
        var ex = /^(((\d{2}((0[13578]|1[02])(0[1-9]|[12]\d|3[01])|(0[13456789]|1[012])(0[1-9]|[12]\d|30)|02(0[1-9]|1\d|2[0-8])))|([02468][048]|[13579][26])0229))(( |-)(\d{4})( |-)(\d{3})|(\d{7}))/;
        
        return ex.test(idNumber);
    }

}