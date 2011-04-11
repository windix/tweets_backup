class DeadWeightTasks < Thor
  desc "run_check", "run DeadWeight CSS check"
  def run_check
    dw = Deadweight.new
    dw.stylesheets = ["/stylesheets/default.css"]
    dw.pages = ["/", "/tweets/index", "/favorites/index", "/formatted.html"]
    puts dw.run
  end 
end