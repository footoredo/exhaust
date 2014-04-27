require 'mechanize'
require 'open-uri'

class BZOJExhaust
	def initialize
		@agent = Mechanize.new

		page = @agent.get('http://www.lydsy.com/JudgeOnline/loginpage.php')
		form = page.forms.first
		form.field_with(:name => 'user_id').value = 'exhaust'
		form.field_with(:name => 'password').value = '123456'
		form.click_button
	end

	def agent
		@agent
	end

	class Problem
		def initialize(id)
			@id = id
		end
		def id
			@id
		end
	end

	module Language
		def Language.id(name)
			name.downcase!
			id =
				case name
				when 'c'
					0
				when 'c++'
					1
				when 'pascal'
					2
				when 'java'
					3
				when 'Ruby'
					4
				when 'bash'
					5
				when 'python'
					6
				end
		end

		def Language.name(id)
			list = [ 'C', 'C++', 'Pascal', 'Java', 'Ruby', 'Bash', 'Python' ]
			list[id]
		end
	end

	class Status
		def problem
			@problem
		end

		def problem=(problem)
			@problem = problem
		end

		def language
			Language::name(@language_id)
		end

		def language=(name)
			@language_id = Language::id(name)
		end

		def result
			@result
		end

		def result=(result)
			@result = result
		end

		def time
			@time
		end

		def time=(time)
			@time = time
		end

		def memory
			@memory
		end

		def memory=(memory)
			@memory = memory
		end
	end

	class Bullet
		def initialize(run_id, agent)
			@run_id = run_id
			@agent = agent
		end

		def status
			page = @agent.get('http://www.lydsy.com/JudgeOnline/showsource.php?id=' + @run_id.to_s)
			doc = Nokogiri::HTML(page.body)
			text = doc.to_html.to_s

			status = Status.new
			status.problem 	= Problem.new(text[/Problem: (.*?)\n/, 1].to_i)
			status.language = text[/Language: (.*?)\n/, 1]
			status.result		= text[/Result: (.*?)\n/, 1]
			status.time			= text[/Time:(.*?)\n/, 1]
			status.memory		= text[/Memory:(.*?)\n/, 1]

			status
		end
	end

	def trigger(problem, language, filename)
		language_id = Language.id(language)
		code = IO.read(filename)

		page = @agent.get('http://www.lydsy.com/JudgeOnline/submitpage.php?id=' + problem.id.to_s)
		form = page.forms[0]
		form.field_with(:name => 'language').options[language_id].select
		form.field_with(:name => 'source').value = code

		form.click_button
		Bullet.new(track, @agent)
	end

	def track
		page = @agent.get('http://www.lydsy.com/JudgeOnline/status.php')
		form = page.forms[0]
		form.field_with(:name => 'user_id').value = 'exhaust'
		page = form.click_button

		doc = Nokogiri::HTML(page.body)
		run_id = doc.xpath('//tr[@class="evenrow"]/td')[0].text
	end
end

def test
	bzojexhaust = BZOJExhaust.new
	bullet =  bzojexhaust.trigger(BZOJExhaust::Problem.new(1000), 'C++', '1000.cpp')
	#bullet = BZOJExhaust::Bullet.new( bzojexhaust.track, bzojexhaust.agent )
	sleep(3)
	status = bullet.status
	p status.problem.id
	p status.language
	p status.result
	p status.time
	p status.memory
end

#test
#p BZOJExhaust.track