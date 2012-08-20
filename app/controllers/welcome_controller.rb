class WelcomeController < ApplicationController
  before_filter :clear_objects, :only => [:index, :execute]


  def index
  end

  def execute
    if request.xhr?
      output_file = "#{Time.now.to_i}.txt"
      Thread.new{
        system("#{params['command']} > #{output_file}")
        session[:completed_at] = Time.now.to_i
        logger.info session[:completed_at]
      }.run
      session[:file] = output_file
      redirect_to :action => :show_result
    end
  end

  def show_result
    @done = false
    if session[:completed_at].to_i > 0 and session[:last_read_at].to_i > session[:completed_at].to_i
      @done = true
      logger.info session[:last_read_at]
      logger.info session[:completed_at]
      return
    end
    @buffer = ""
    begin
      File.open(session[:file]).each_line { |data|
        @buffer += "#{data}<br/>"
      }
      session[:last_read_at] = Time.now.to_i
    rescue Exception => exp
      logger.info "EXCEPTION ========= #{exp.message} ==========="
      logger.info exp.backtrace
      session[:last_read_at] = Time.now.to_i
      @done = true
      return
    end
  end

  def clear_objects
    session[:file] = nil
    session[:completed_at] = 0
    session[:last_read_at] = 0
    @done = false
  end
end
