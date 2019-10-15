class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    session['sort'] = params['sort'] if !params['sort'].blank?
    session['ratings'] = params['ratings'] if !params['ratings'].blank?

    @all_ratings = Movie.all_ratings
    @selected_ratings = session['ratings'] || {}

    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, true]}]
    else
      @selected_ratings = @selected_ratings.select{|k,v | v="true"}
    end

    sort_by = session['sort']
    if sort_by == 'title'
      # @movies = Movie.with_ratings(@selected_ratings).order(:title)
      order_by = {:title => :asc}
      @title_header_class = "hilite bg-warning"
    elsif sort_by == 'release_date'
      # @movies = Movie.with_ratings(@selected_ratings).order(release_date: :desc)
      order_by = {:release_date => :desc}
      # @movies = Movie.all.order(:release_date)
      @release_date_header_class = "hilite bg-warning"
    else
      order_by = {}
    end

    @movies = Movie.with_ratings(@selected_ratings.keys).order(order_by)

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
