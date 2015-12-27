module ApplicationHelper

  def glyphicon_edit
		'<span class="glyphicon-class glyphicon glyphicon-pencil" title="Edit" aria-hidden="true"></span>'
	end

	def glyphicon_delete
		'<span class="glyphicon-class glyphicon glyphicon-trash" title="Delete" aria-hidden="true"></span>'
	end

	def glyphicon_add
		'<span class="glyphicon-class glyphicon glyphicon-plus-sign control-icon" aria-hidden="true"></span> Add new'
	end

	def browser_date(time_value)
		time_value.utc.in_time_zone(Time.zone).strftime("%m/%d/%Y")
	end

end
