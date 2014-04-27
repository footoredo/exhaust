require 'mechanize'
require 'open-uri'

class POJExhaust
	def initialize
		@agent = Mechanize.new

		page = @agent.get('http://poj.org/login')
		form = page.forms.first
		form.field_with(:name => 'user_id1').value = 'exhaust'
		form.field_with(:name => 'password1').value = '123456'
		form.click_button
	end

	class Problem
		def initialize(id)
			@id = id
		end
		def id
			@id
		end
	end

	def trigger(problem, language_id, filename)
		code = IO.read(filename)

		page = @agent.get('http://poj.org/submit')
		form = page.forms[2]
		form.field_with(:name => 'problem_id').value = problem.id
		form.field_with(:name => 'language').options[language_id].select
		form.field_with(:name => 'source').value = code

		form.click_button
	end
end

def test
	pojexhaust = POJExhaust.new
	pojexhaust.trigger(POJExhaust::Problem.new(1000), 0, '1000.cpp')
end