var ready;

ready = function() {
     $('.datepicker').datepicker({"format": "yyyy-mm-dd", "weekStart": 1, "autoclose": true});
};

$(document).ready(ready);
$(document).on('page:load', ready);