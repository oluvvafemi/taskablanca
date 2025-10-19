class SearchController < ApplicationController
  def index
    @query = params[:q]&.strip
    @results = { tasks: [], projects: [] }

    if @query.present?
      @results[:tasks] = Current.user.tasks
                                  .includes(:project, :users)
                                  .search(@query)
                                  .limit(10)
      @results[:projects] = Current.user.projects
                                    .includes(:organization)
                                    .search(@query)
                                    .limit(10)
    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end
end
