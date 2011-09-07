class Heroku::Command::Newrelic < Heroku::Command::Base
  # newrelic:javaagent [NAME]
  #
  # download and install the newrelic javaagent into ./newrelic/
  # add or prompt user to add -javaagent:newrelic/newrelic.jar to JAVA_OPTS
  # commit or prompt to commit, push or prompt to push 
  #
  # -o, --opts    # execute heroku config:add on behalf of the user and add javaagent to JAVA_OPTS
  # -c, --commit  # execute git add . && git commit -m 'add newrelic' on behalf of user 
  # -p, --push    # execute git push heroku master on behalf of the user
  #
  def javaagent
    download = "http://download.newrelic.com/newrelic/java-agent/newrelic-api/2.0.4/newrelic_agent2.0.4.zip"
    timeout = extract_option('--timeout', 30).to_i
    display(download)
  end
end
