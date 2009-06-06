class IndexController < ApplicationController

  def index
    if logged_in?
      # load stuff for the overview
      
      # get activities associated with the current user
      @activities = Activity.paginate_by_user_id current_user.id, :page => params[:activity_page], :per_page => Activity.per_page, :order => 'date DESC'

      # fitness samples associated with the current user
      @fitness_samples = FitnessSample.paginate_by_user_id current_user.id, :page => params[:fs_page], :per_page => FitnessSample.per_page, :order => 'date DESC'

      # get the climbs associated with activities associated with the current user
      @climbs = Climb.paginate_by_sql "SELECT c.* FROM climbs c, users u, activities a WHERE u.id = #{current_user.id.to_s} AND u.id = a.user_id AND a.id = c.activity_id ORDER BY a.date DESC", :page => params[:climb_page], :per_page => Climb.per_page

      render :template => 'index/index'
    else
      redirect_to :controller => 'index', :action => 'login' and return true
    end
  end

  def login
    if !params[:login].nil? && !params[:password].nil? && session[:errprs].nil?
      self.current_user = User.authenticate(params[:login], params[:password])

      unless logged_in?
        flash[:notice] = "Incorrect login or password."
        return
      end

      session[:user_id] = self.current_user.id
    end

    if logged_in?
      flash[:notice] = "Logged in successfully."

      redirect_to :controller => 'index', :action => 'index' and return true
    else
      render :template => 'index/login'
    end
  end

  def logout
    reset_session

    redirect_to :controller => 'index', :action => 'index' and return true
  end

  def graph_weight
    ghelper = GraphHelper.new

    # get the fitness sample data sets for this user
    @fitness_samples = FitnessSample.find_all_by_user_id current_user.id, :order => 'date ASC'
    weight_data_set = ghelper.fitness_samples_to_weight_data_set(@fitness_samples)
    data_sets = []
    data_sets << weight_data_set

    graph = ghelper.generate_graph(data_sets)

    # WILL this work?  Really?  Rails will just DO this?
    send_data(graph.to_blob, :disposition => 'inline', :type => 'image/png', :filename => 'arbitraryfilename.png')
  end

  def graph_body_fat_percentage
    ghelper = GraphHelper.new

    # get the fitness sample data sets for this user
    @fitness_samples = FitnessSample.find_all_by_user_id current_user.id, :order => 'date ASC'
    bf_percent_data_set = ghelper.fitness_samples_to_body_fat_percentage_data_set(@fitness_samples)
    data_sets = []
    data_sets << bf_percent_data_set

    graph = ghelper.generate_graph(data_sets)

    # WILL this work?  Really?  Rails will just DO this?
    send_data(graph.to_blob, :disposition => 'inline', :type => 'image/png', :filename => 'arbitraryfilename.png')
  end

  def graph_hours
    ghelper = GraphHelper.new

    # get the fitness sample data sets for this user
    @fitness_samples = FitnessSample.find_all_by_user_id current_user.id, :order => 'date ASC'
    total_hours_data_set = ghelper.fitness_samples_to_seven_day_hours_total_data_set(@fitness_samples)
    data_sets = []
    data_sets << total_hours_data_set

    graph = ghelper.generate_graph(data_sets)
    graph.minimum_value = 0

    # WILL this work?  Really?  Rails will just DO this?
    send_data(graph.to_blob, :disposition => 'inline', :type => 'image/png', :filename => 'arbitraryfilename.png')
  end

end
