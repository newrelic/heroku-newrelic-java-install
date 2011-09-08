require 'heroku/command/base'
require 'net/http'

class Heroku::Command::Newrelic < Heroku::Command::BaseWithApp
  # newrelic:javaagent 
  #
  # install the newrelic javaagent into ./newrelic/
  # add or prompt user to add -javaagent:newrelic/newrelic.jar to JAVA_OPTS
  # commit or prompt to commit, push or prompt to push 
  #
  # -n, --noopts    # supress execution of heroku config:add on behalf of the user and add javaagent to JAVA_OPTS if JAVA_OPTS exists
  # -c, --commit  # execute git add . && git commit -m 'add newrelic' on behalf of user 
  # -p, --push    # execute git push heroku master on behalf of the user
  # -v, --version VERSION # versoion of newrelic to download, default 2.0.4
  #
  def javaagent
    unpack_newrelic
  	process_java_opts ##actually shouldnt do this till the commit and push since it will break apps before the push
  	process_commit
  	process_push
  end

protected
   
  def unpack_newrelic
    version = '2.0.4' #extract_option('--version', '2.0.4')
    display(version)
    zip = home_directory + "/.heroku/plugins/heroku-newrelic/resources/newrelic_agent#{version}.zip"
    display(zip)
    if ! File.exists? zip
    	download(version, zip)
    end
    FileUtils.copy(zip, Dir.pwd)
    display("unpacking newrelic in #{Dir.pwd}/newrelic")
    system "jar xf newrelic_agent#{version}.zip"
    FileUtils.rm "newrelic_agent#{version}.zip"
  end
   
  def process_java_opts
    jopts = 'JAVA_OPTS'
    agent = '-javaagent:newrelic/newrelic.jar'
    vars = heroku.config_vars(app)
    if vars.key?(jopts)
    	if(vars[jopts] =~ /javaagent/) != nil
        display("It appears you have a javaagent defined in #{jopts}")
    	else 
      	newjopts = "#{jopts}=#{vars[jopts]} #{agent}"
      	if extract_option("--noopts", false)
      	  display("You elected to skip adding the javaagent to #{jopts}")
      	  display("To add it in the future, run herkou config add #{newjopts}")
    	  else
    	  	display("Running heroku config:add '#{newjopts}'")
    			run_command("config:add", [newjopts])  
    	  end
      end
    else
      display("No heroku config var #{jopts} was found. You should add #{agent} to the command(s) that start JVMs in your app")
    end
  end
  
  def process_commit
  	 if extract_option("--commit", false)
  	 
  	 else
  	    display("You should run git add newrelic && git commit -m 'add newrelic' to add newrelic to your project")
  	 end
  end
   
	def process_push
  	 if extract_option("--commit", false) && extract_option("--push", false)
  	 
  	 else
  	    git_remotes.keys.each do |remote|
  	    	display("You should run git push #{remote} master to activate newrelic for this app")
				end
  	 end
  end
	
	def download(version, to)
	  zipfile = "/newrelic/java-agent/newrelic-api/#{version}/newrelic_agent#{version}.zip"
		display("downloading #{zipfile}")
		Net::HTTP.start("download.newrelic.com") do |http|
    	resp = http.get(zipfile)
    	open(to, "wb") do |file|
       	file.write(resp.body)
  		end
		end
		display("Done.")
  end
  
end
