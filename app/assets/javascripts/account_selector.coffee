
window.new_user_from = ->
  timeNow = new Date().toLocaleTimeString()
  console.log("Ran new_user_from " + timeNow)
  if document.getElementById("payment_from_user_id").selectedIndex == 1
    $("#new_guest_from").collapse('show')
    document.getElementById("is_new_user_from").value = true
    document.getElementById("account_from_status").value = "new_user"
  else
    document.getElementById("account_from_status").value = "user_account"

window.cancel_new_user_from = ->
  timeNow = new Date().toLocaleTimeString()
  console.log("Ran cancel_new_user_from " + timeNow)
  document.getElementById("payment_from_user_id").selectedIndex = "0"
  $("#new_guest_from").collapse('hide')
  document.getElementById("is_new_user_from").value = false
  document.getElementById("account_from_status").value = "event_account"

window.new_user_to = ->
  timeNow = new Date().toLocaleTimeString()
  console.log("Ran new_user_to " + timeNow)
  if document.getElementById("payment_to_user_id").selectedIndex == 1
    $("#new_guest_to").collapse('show')
    document.getElementById("is_new_user_to").value = true
    document.getElementById("account_to_status").value = "new_user"
  else
    document.getElementById("account_to_status").value = "user_account"

window.cancel_new_user_to = ->
  timeNow = new Date().toLocaleTimeString()
  console.log("Ran cancel_new_user_to " + timeNow)
  document.getElementById("payment_to_user_id").selectedIndex = "0"
  $("#new_guest_to").collapse('hide')
  document.getElementById("is_new_user_to").value = false
  document.getElementById("account_to_status").value = "event_account"

window.set_hidden_field = (fieldId, newValue) ->
  timeNow = new Date().toLocaleTimeString()
  console.log("Ran set_hidden_field" + timeNow)
  hiddenField = document.getElementById(fieldId)
  hiddenField.value = newValue