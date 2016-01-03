ready = ->
     $("#flash-alert").delay(2000).fadeOut(1000)
     timeNow = new Date().toLocaleTimeString()
     console.log("Ran flashCallback " + timeNow)

$(document).ready(ready)
$(document).on('page:change', ready)
