ready = ->
  source = $('#to_source').data('type')
  switch source
    when "Event" then $("#payment_form").collapse('show')
    when "User" then $('#user_payment_form').collapse('show')
    else

  # $('#new_guest_from').on 'show.bs.collapse', ->
  #   alert "It worked!"


window.toggle_new_user = (direction, namespace) ->
  timeNow = new Date().toLocaleTimeString()
  new_user = document.getElementById("is_new_user_" + direction)
  type = document.getElementById("account_" + direction + "_type")
  user = document.getElementById("payment_" + direction + "_user_id")
  index = document.getElementById("account_" + direction + "_index")
  console.log("Ran toggle_new_user " + timeNow)  
  $( "#new_guest_" + direction + "_" + namespace ).collapse('toggle')
  if new_user.value == "true"
    index.value = user.selectedIndex
    user.selectedIndex = 0
    new_user.value = "false"
    type.value = "new_user"
  else
    user.selectedIndex = index.value
    index.value = 0
    new_user.value = "true"
    type.value = "user_account"

window.set_hidden_field = (fieldId, newValue) ->
  timeNow = new Date().toLocaleTimeString()
  console.log("Ran set_hidden_field" + timeNow)
  hiddenField = document.getElementById(fieldId)
  hiddenField.value = newValue

$(document).ready(ready)
$(document).on('page:change', ready)