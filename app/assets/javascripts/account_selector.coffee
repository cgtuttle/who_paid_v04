ready = ->
  source = $('#to_source').data('type')
  switch source
    when "Event" then $("#payment_form").collapse('show')
    when "User" then $('#user_payment_form').collapse('show')
    else

$(document).ready(ready)
$(document).on('page:change', ready)


window.toggle_new_user = (direction) ->
  timeNow = new Date().toLocaleTimeString()
  new_user = document.getElementById("is_new_user_" + direction)
  status = document.getElementById("account_" + direction + "_status")
  user = document.getElementById("payment_" + direction + "_user_id")
  index = document.getElementById("account_" + direction + "_index")
  console.log("Ran toggle_new_user" + timeNow)
  if new_user.value == "true"
    index.value = user.selectedIndex
    user.selectedIndex = 0
    $("#new_guest_" + direction).collapse('show')
    new_user.value = "false"
    status.value = "new_user"
  else
    user.selectedIndex = index.value
    index.value = 0
    $("#new_guest_" + direction).collapse('hide')
    new_user.value = "true"
    status.value = "user_account"

window.set_hidden_field = (fieldId, newValue) ->
  timeNow = new Date().toLocaleTimeString()
  console.log("Ran set_hidden_field" + timeNow)
  hiddenField = document.getElementById(fieldId)
  hiddenField.value = newValue