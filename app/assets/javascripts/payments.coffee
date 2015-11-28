ready = ->
	$('#payment_payee_name').autocomplete
		source: $('#payment_payee_name').data('autocomplete-source')

	$('#payment_payer_name').autocomplete
		source: $('#payment_payer_name').data('autocomplete-source')

$(document).ready(ready)
$(document).on('page:change', ready)
