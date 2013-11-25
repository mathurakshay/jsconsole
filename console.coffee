cmd_history = []
cmd_index = null
$(document).ready ->
	iframe_height = $(window).height() - 175
	$("#sandbox").css('height', iframe_height)
	output_height = $(window).height() - 100
	$("#output").css('min-height', output_height)
	fill_dom()
	fill_autocomplete(window)

	$("#cmd_input").keypress (ev)->
		if ev.which == 13
			#execute command on enter
			cmd_to_eval = $.trim $(this).val()
			return if cmd_to_eval is ''
			cmd_history.push cmd_to_eval
			cmd_output = run_cmd cmd_to_eval
			cmd_index = cmd_history.length
			log_cmd cmd_to_eval, cmd_output
			$(this).val('')
	$("#cmd_input").keyup (ev)->
		if ev.which == 38 and $(".ac_results:visible").length is 0
			#show previous command on left-arrow
			cmd_index--
			cmd_index = 0 if cmd_index < 0
			show_history()
		else if ev.which == 40 and $(".ac_results:visible").length is 0
			#show next command on right-arrow
			cmd_index++
			cmd_index = cmd_history.length if cmd_index > cmd_history.length
			show_history()
		else if ev.which == 190
			# fill in autocomplete options when '.' is pressed
			cmd_to_eval = $.trim $(this).val().slice(0, -1)
			return if cmd_to_eval is ''
			sandbox_window = $("#sandbox")[0].contentWindow
			try
				retval = sandbox_window.eval cmd_to_eval
			catch e
				retval = ''
			
			fill_autocomplete retval


	$("#script_input").keyup (ev)->
		return if ev.which isnt 13
		script_url = $.trim $(this).val()
		cmd_to_eval = "var head = document.getElementsByTagName('head')[0] || document.documentElement;
						var script = document.createElement('script');
						script.type = 'text/javascript';
						script.src = '#{script_url}';
						head.appendChild(script);
						if (script.readyState){
							script.onreadystatechange = function () {
								var state = this.readyState;
								if (state === 'loaded' || state === 'complete') {
									script.onreadystatechange = null;
									top.log_cmd('Load Script #{script_url}', 'Loaded');
								}
							};
						} else {
							script.onload = function(){
								top.log_cmd('Load Script #{script_url}', 'Loaded');
							};
						}
						script.onerror = function(){
							top.log_cmd('Load Script #{script_url}', 'Failed');
						};"
		cmd_output = run_cmd cmd_to_eval
		$(this).val('')

	$("#css_input").keyup (ev)->
		return if ev.which isnt 13
		script_url = $.trim $(this).val()
		cmd_to_eval = "var head = document.getElementsByTagName('head')[0] || document.documentElement;
						var link = document.createElement('link');
						link.type = 'text/css';
						link.rel = 'stylesheet';
						link.href = '#{script_url}';
						head.appendChild(link);
						if (link.readyState){
							link.onreadystatechange = function () {
								var state = this.readyState;
								if (state === 'loaded' || state === 'complete') {
									link.onreadystatechange = null;
									top.log_cmd('Load CSS #{script_url}', 'Loaded');
								}
							};
						} else {
							link.onload = function(){
								top.log_cmd('Load CSS #{script_url}', 'Loaded');
							};
						}
						link.onerror = function(){
							top.log_cmd('Load CSS #{script_url}', 'Failed');
						};"
		cmd_output = run_cmd cmd_to_eval
		$(this).val('')

	return

run_cmd = (cmd_to_eval)->
	sandbox_window = $("#sandbox")[0].contentWindow
	try
		retval = sandbox_window.eval cmd_to_eval
		if $.isFunction retval
			retval
		else if $.isArray retval
			JSON.stringify retval
		else if typeof retval is 'object'
			obj_arr = []
			obj_arr.push retval
			for k, v of retval
				obj_arr.push "#{k}: #{v}"
			obj_arr.join('<br />')
		else
			JSON.stringify retval
	catch e
		e

log_cmd = (cmd_to_eval, cmd_output) ->
	a = $ "<li class='text-info'>#{cmd_to_eval}
			<ul class='list-unstyled text-muted'>
				<li class='op_' style='overflow:auto;'>#{cmd_output}</li>
			</ul>
		</li>"
	a.find(".op_").jTruncate({length: 100})

	$("#output").prepend a
	return

show_history = ->
	try
		cmd_to_show = cmd_history[cmd_index]
		$("#cmd_input").val(cmd_to_show)
	catch e
		$("#cmd_input").val('')

fill_autocomplete = (obj)->
	if typeof obj is 'object'
		obj_arr = []
		for k, v of obj
			obj_arr.push k
		#$("#cmd_input").unautocomplete()
		$("#cmd_input").autocomplete obj_arr,
			autoFill: true
			minChars: 0
		return

fill_dom = ->
	dom_html = "<h3>Welcome</h3>
		<div>This place is to display output of the DOM manipulation command you try.</div>
		<div>You can also load JS and CSS files here.</div>
		<br />
		<div>Jquery and Bootstrap are placed in path for your help. So you can directly try <b>jquery.js</b> or <b>bootstrap.css</b>.</div>
		"
	run_cmd "document.body.innerHTML = '#{dom_html}'"

window.log_cmd = log_cmd
